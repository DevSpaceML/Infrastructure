# Ephemeral Foundation - Networking, IAM, Cluster, Addons, Nodes

terraform {
  required_version = ">= 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.36.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_eks_cluster_auth" "eph_cluster" {
  name = var.clustername
}

provider "kubernetes" {
   host = module.eph_cluster.cluster_endpoint
   cluster_ca_certificate = module.eph_cluster.cluster_certificate

   exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.clustername, "--region", var.region]
  }
}

provider "helm" {
  kubernetes = {
    host                   = module.eph_cluster.cluster_endpoint
    cluster_ca_certificate = module.eph_cluster.cluster_certificate

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks", "get-token",
        "--cluster-name", var.clustername,
        "--region",       var.region
      ]
    }
  }
}

module "network" {
  source = "../../../modules/network/eks/vpc"
  cidr                               = var.cidr
  vpcname                            = var.vpcname
  region                             = var.region
  createvpc                          = var.createvpc
  vpc_id                             = var.vpc_id
  clustername                        = var.clustername
}

module "iam" {
  source = "../../../modules/security/iam/eks"
}

locals {
  vpc_id = module.network.outputs.vpc_id
  public_subnet_id_list = module.network.outputs.public_subnet_id_list
  private_subnet_id_list = module.network.outputs.private_subnet_id_list
  nodegroup_subnet_id_list = module.network.outputs.nodegroup_subnet_id_list
  clustername = var.clustername
  region = var.region
  cluster_role_arn = module.iam.outputs.cluster-role-arn
  node_role_arn = module.iam.outputs.node-mgr-arn
  DevOpsAdminSre_arn = module.iam.outputs.DevOpsAdminSre-arn
  techlead_arn = module.iam.outputs.techlead-arn
  access_entries_map = module.iam.outputs.access-entries-map
  github_actions_arn = module.iam.outputs.github-actions-arn
}

module "eph_cluster" {
  source                 = "../../../modules/compute/eks/cluster"
  clustername            = local.clustername
  region                 = local.region
  vpcId                  = local.vpc_id
  public_subnet_ids      = local.public_subnet_id_list
  private_subnet_ids     = local.private_subnet_id_list
  cluster_role_arn       = local.cluster_role_arn
  node_role_arn          = local.node_role_arn
  devops_admin_arn       = local.DevOpsAdminSre_arn
  access_entries         = merge(local.access_entries_map, {
                                  "github_actions" = {
                                     principal_arn     = local.github_actions_arn
                                     policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
                                    },
                                    "devops_admin" = {
                                      principal_arn = local.DevOpsAdminSre_arn
                                      policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
                                    }
                              })
}

module "eks_security_groups" {
  depends_on            = [ module.eph_cluster ]
  source                = "../../../modules/network/eks/eks-security-groups"
  vpc_id                = local.vpc_id
  clustername           = local.clustername
}

module "k8_auth" {
  depends_on = [ module.iam, module.eph_cluster ]
  source           = "../../../modules/security/auth"
  clustername      = local.clustername
  noderolearn      = local.node_role_arn
  clusteradminrole = local.cluster_role_arn
  DevOpsAdminSre   = local.DevOpsAdminSre_arn
  techlead         = local.techlead_arn
  hosturl          = module.eph_cluster.outputs.cluster_endpoint
  cluster_cert     = module.eph_cluster.outputs.cluster_cert
  region           = local.region
}

module "vpc_cni" {
  depends_on  = [ module.eph_cluster, module.eks_security_groups ]
  source      = "../../../modules/compute/eks/addons/vpc-cni"
  clustername = local.clustername
  rolearn     = local.node_role_arn
}

module "kube_proxy" {
  depends_on = [ module.eph_cluster, module.vpc_cni ]
  source = "../../../modules/compute/eks/addons/kube_proxy"
  clustername = local.clustername
}

module "oidc_auth" {
  depends_on = [ module.eph_cluster, module.vpc_cni, module.kube_proxy ]
  source = "../../../modules/compute/eks/addons/oidc"
  clustername = local.clustername
}

module "eph_nodes" {
  depends_on = [ module.eph_cluster, module.oidc_auth ]
  source                       = "../../../modules/compute/eks/nodegroups"
  node_group_mgr_arn           = local.node_role_arn
  nodegroupname                = "${local.clustername}-nodegroup"
  clustername                  = local.clustername
  instancetype                 = var.instancetype
  nodegroup_pvt_subnet_id_list = var.createvpc ? local.nodegroup_subnet_id_list : []
}

module "coredns" {
  depends_on = [module.eph_cluster, module.eph_nodes, module.oidc_auth ]
  source = "../../../modules/compute/eks/addons/coredns"
  clustername = local.clustername
}
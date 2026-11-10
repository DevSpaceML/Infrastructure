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
   host = module.cluster.cluster_endpoint
   cluster_ca_certificate = module.cluster.cluster_certificate

   exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.clustername, "--region", var.region]
  }
}

provider "helm" {
  kubernetes = {
    host                   = module.cluster.cluster_endpoint
    cluster_ca_certificate = module.cluster.cluster_certificate

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
  depends_on = [ module.network ]

  source = "../../../modules/security/iam/eks"
}

module "cluster" {
  depends_on = [ module.network, module.iam ]

  source                 = "../../../modules/compute/eks/cluster"
  clustername            = var.clustername
  region                 = var.region
  vpcId                  = module.network.vpc_id
  public_subnet_ids      = module.network.public_subnet_id_list
  private_subnet_ids     = module.network.private_subnet_id_list
  cluster_role_arn       = module.iam.cluster_role_arn
  node_role_arn          = module.iam.node_manager_role_arn
  devops_admin_arn       = module.iam.devops_admin_arn
  access_entries         = merge(module.iam.access_entries, {
                                  "github_actions" = {
                                     principal_arn     = module.iam.github_actions_role_arn
                                     policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
                                    },
                                    "devops_admin" = {
                                      principal_arn = module.iam.devops_admin_arn
                                      policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
                                    }
                              })
}

module "eks_security_groups" {
  depends_on            = [ module.cluster ]
  source                = "../../../modules/network/eks/eks-security-groups"
  vpc_id                = module.network.vpc_id
  clustername           = module.cluster.cluster_name
}

module "k8_auth" {
  depends_on = [ module.iam, module.cluster, module.eks_security_groups ]
  source           = "../../../modules/security/auth"
  clustername      = module.cluster.cluster_name
  deployment_role  = module.iam.github_actions_role_arn
  noderolearn      = module.iam.node_manager_role_arn
  clusteradminrole = module.iam.cluster_role_arn
  DevOpsAdminSre   = module.iam.devops_admin_arn
  techlead         = module.iam.techlead_developer_arn
  hosturl          = module.cluster.cluster_endpoint
  cluster_cert     = module.cluster.cluster_certificate
  region           = var.region
}

module "vpc_cni" {
  depends_on  = [ module.cluster, module.eks_security_groups ]
  source      = "../../../modules/compute/eks/addons/vpc-cni"
  clustername = module.cluster.cluster_name
  rolearn     = module.iam.node_manager_role_arn
}

module "kube_proxy" {
  depends_on = [ module.cluster, module.vpc_cni ]
  source = "../../../modules/compute/eks/addons/kube_proxy"
  clustername = module.cluster.cluster_name
}

module "oidc_auth" {
  depends_on = [ module.cluster, module.vpc_cni, module.kube_proxy ]
  source = "../../../modules/compute/eks/addons/oidc"
  clustername = module.cluster.cluster_name
}

module "nodes" {
  depends_on = [ module.cluster, module.oidc_auth ]
  source                       = "../../../modules/compute/eks/nodegroups"
  node_group_mgr_arn           = module.iam.node_manager_role_arn
  nodegroupname                = "${module.cluster.cluster_name}-nodegroup"
  clustername                  = module.cluster.cluster_name
  instancetype                 = var.instancetype
  nodegroup_pvt_subnet_id_list = module.network.nodegroup_pvt_subnet_id_list
}

module "coredns" {
  depends_on = [module.cluster, module.nodes, module.oidc_auth ]
  source = "../../../modules/compute/eks/addons/coredns"
  clustername = module.cluster.cluster_name
}
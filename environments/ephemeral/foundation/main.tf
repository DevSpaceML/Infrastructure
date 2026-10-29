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
  name = module.eph_cluster.cluster_name
}

provider "kubernetes" {
   host = module.eph_cluster.cluster_endpoint
   cluster_ca_certificate = module.eph_cluster.cluster_certificate

   exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eph_cluster.cluster_name, "--region", var.region]
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
        "--cluster-name", module.eph_cluster.cluster_name,
        "--region",       var.region
      ]
    }
  }
}

module "network" {
  source = "../modules/network/eks/vpc"
}

module "iam" {
  source = "../modules/iam"
}

module "eph_cluster" {
  source                 = "../../modules/compute/eks/cluster"
  clustername            = var.clustername
  region                 = var.region
  vpcId                  = module.network.vpc_id
  public_subnet_ids      = module.network.public_subnet_id_list
  private_subnet_ids     = module.network.private_subnet_id_list
  cluster_role_arn       = module.iam.outputs.cluster-role-arn
  node_role_arn          = module.iam.outputs.node-mgr-arn
  devops_admin_arn       = module.iam.outputs.DevOpsAdminSre-arn
  access_entries         = merge(module.iam.outputs.access-entries-map, {
                                  "github_actions" = {
                                     principal_arn     = module.iam.outputs.github-actions-arn
                                     policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
                                    },
                                    "devops_admin" = {
                                      principal_arn = module.iam.outputs.DevOpsAdminSre-arn
                                      policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
                                    }
                              })
}

module "eks_security_groups" {
  depends_on            = [ module.eph_cluster ]
  source                = "../../../../modules/network/eks/eks-security-groups"
  vpc_id                = module.network.vpc_id
  clustername           = module.eph_cluster.cluster_name
}

module "vpc_cni" {
  depends_on  = [ module.eph_cluster, module.eks_security_groups ]
  source      = "../../../../modules/compute/eks/addons/vpc-cni"
  clustername = module.eph_cluster.cluster_name
  rolearn     = module.iam.outputs.node-mgr-arn
}

module "kube_proxy" {
  depends_on = [ module.eph_cluster, module.vpc_cni ]
  source = "../../../../modules/compute/eks/addons/kube_proxy"
  clustername = module.eph_cluster.cluster_name
}

module "oidc_auth" {
  depends_on = [ module.eph_cluster, module.vpc_cni, module.kube_proxy ]
  source = "../../../../modules/compute/eks/addons/oidc"
  clustername = module.eph_cluster.cluster_name
}

module "eph_nodes" {
  depends_on = [ module.eph_cluster, module.oidc_auth ]
  source                       = "../../../../modules/compute/eks/nodegroups"
  node_group_mgr_arn           = module.iam.outputs.node-mgr-arn
  nodegroupname                = "${module.eph_cluster.cluster_name}-nodegroup"
  clustername                  = module.eph_cluster.cluster_name
  instancetype                 = var.instancetype
  nodegroup_pvt_subnet_id_list = module.network.nodegroup_subnet_id_list
}

module "coredns" {
  depends_on = [module.eph_cluster, module.eph_nodes, module.oidc_auth ]
  source = "../../../../modules/compute/eks/addons/coredns"
  clustername = module.eph_cluster.cluster_name
}
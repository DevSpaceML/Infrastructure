terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.36.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

module "dev_vpc" {
  source  = "../../modules/network/vpc"
  cidr    = var.dev_cidr
  vpcname = var.vpcname
}

module "iam" {
  source = "../../modules/security/iam"
}

module "dev_cluster" {
  depends_on        = [module.dev_vpc]
  source            = "../../modules/compute/eks/cluster"
  kubeadmin-arn     = var.kubeadmin-arn
  devops_user       = var.devops_user
  clustername       = var.clustername
  vpcId             = module.dev_vpc.eks_vpc_id
  public_subnet_ids = module.dev_vpc.public_subnets
  public_cidr       = module.dev_vpc.public_cidr
  cluster_role_arn  = module.iam.cluster_role_arn
  access_entries    = var.access_entries

}

module "dev_nodes" {
  depends_on         = [module.dev_cluster, module.iam]
  source             = "../../modules/compute/eks/nodegroups"
  node_group_mgr_arn = module.iam.node_manager_role_arn.arn
  nodegroupname      = var.nodegroupname
  eksclustername     = module.dev_cluster.cluster_name
  private_subnet_Ids = module.dev_vpc.private_subnets
}

data "aws_eks_cluster_auth" "devcluster" {
  name = module.dev_cluster.cluster_name
}

# Allow provider to be passed from caller
provider "kubernetes" {
  alias                  = "this"
  host                   = module.dev_cluster.cluster_endpoint
  cluster_ca_certificate = module.dev_cluster.cluster_certificate
  token                  = data.aws_eks_cluster_auth.devcluster.token
}

module "auth" {
  depends_on = [module.dev_cluster, module.dev_nodes]

  source         = "../../modules/security/auth"
  eksclustername = module.dev_cluster.cluster_name
  noderolearn    = module.iam.node_manager_role_arn.arn
  hosturl        = module.dev_cluster.cluster_endpoint

  providers = {
    kubernetes = kubernetes.this
  }
}

module "certs" {
  depends_on = [module.dev_cluster, module.auth, module.dev_nodes]

  source             = "../../modules/security/certs"
  security-groups    = module.dev_vpc.eks_security_group_id
  private_cidr_block = module.dev_vpc.private_cidr
  public_cidr_block  = module.dev_vpc.public_cidr
  eks_subnets        = module.dev_vpc.public_subnets
  securitygroupId    = module.dev_vpc.eks_security_group_id
  cluster_vpc_id     = module.dev_vpc.eks_vpc_id
  eksclustername     = module.dev_cluster.cluster_name
}

module "route53" {
  depends_on         = [module.certs]
  source             = "../../modules/dns/route53"
  private_cidr_block = module.dev_vpc.private_cidr
  public_cidr_block  = module.dev_vpc.public_cidr
  securitygroupId    = module.dev_vpc.eks_security_group_id
  ekscertificate     = module.certs.ekscertificate
  certarn            = module.certs.cert_arn
}

module "rds_appdata" {
  depends_on         = [module.dev_vpc]
  source             = "../../modules/database/rds"
  private_subnet_Ids = module.dev_vpc.private_subnets
}
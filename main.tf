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
  region  = "us-east-1"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

module "clustervpc" {
	source = "./modules/clustervpc"
   name = "EksClusterVPC"
}

module "iam" {
  source         = "./modules/iam"
  eksclustername = var.nameofcluster
  vpc_id         = module.clustervpc.eks_vpc_id
}

module "ekscluster" {
  source             = "./modules/ekscluster"
  clustername        = var.nameofcluster
  vpcId              = module.clustervpc.eks_vpc_id
  public_subnet_ids  = module.clustervpc.public_subnets
  private_subnet_Ids = module.clustervpc.private_subnets
  public_cidr        = module.clustervpc.public_cidr
  EksClusterRole-arn = module.iam.EKS_Cluster_Role_Arn
  EksNodeGroupMgrArn = module.iam.Node_Manager_Role_Arn
  
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.ekscluster.cluster_name
}

# Allow provider to be passed from caller
provider "kubernetes" {
  alias = "this"
  host                   = module.ekscluster.cluster_endpoint
  cluster_ca_certificate = module.ekscluster.clustercertificate
  token                  = data.aws_eks_cluster_auth.cluster.token

}

module "auth" {
  depends_on = [ module.ekscluster ]

  source          = "./modules/auth"
  eksclustername  = var.nameofcluster
  noderolearn     = module.iam.Node_Manager_Role_Arn 
  hosturl         = module.ekscluster.cluster_endpoint

  providers = {
    kubernetes = kubernetes.this
  }  
}

module "network" {
  depends_on  = [ module.ekscluster, module.auth ]
  source      = "./modules/network"
  clustername = var.nameofcluster
  rolearn     = module.iam.EKS_Cluster_Role_Arn

  providers = {
    kubernetes = kubernetes.this
  } 
}

module "certs" {
 depends_on         = [ module.network ]

 source             = "./modules/certs"
 security-groups    = module.clustervpc.eks_security_group_id
 private_cidr_block = module.clustervpc.private_cidr
 public_cidr_block  = module.clustervpc.public_cidr
 eks_subnets        = module.clustervpc.public_subnets
 securitygroupId    = module.clustervpc.eks_security_group_id
 cluster_vpc_id     = module.clustervpc.eks_vpc_id
 eksclustername     = var.nameofcluster
}

module "route53" {
  depends_on = [ module.certs ]

  source             = "./modules/route53"
  private_cidr_block = module.clustervpc.private_cidr
  public_cidr_block  = module.clustervpc.public_cidr
  securitygroupId    = module.clustervpc.eks_security_group_id
  ekscertificate     = module.certs.ekscertificate
  certarn            = module.certs.cert_arn   
}
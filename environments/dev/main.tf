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

module dev_vpc {
    source = "../../modules/network/vpc"
    name = var.vpc_name
    cidr = var.dev_cidr
}

module "iam" {
  source = "../../modules/security/iam"
}

module "dev_cluster" {
  depends_on = [ module.dev_vpc ]

  source             = "../../modules/compute/eks/cluster"
  clustername        = var.clustername
  vpcId              = module.dev_vpc.eks_vpc_id
  public_subnet_ids  = module.dev_vpc.public_subnets
  public_cidr        = module.dev_vpc.public_cidr
  EksClusterRole-arn = module.iam.EKS_Cluster_Role_Arn
}

module "dev_nodes" {
  depends_on = [ module.dev_cluster ]

  source             = "../../modules/compute/eks/nodegroups"
  nodegroupname      = var.nodegroupname
  eksclustername     = module.dev_cluster.cluster_name
  EksNodeGroupMgrArn = module.iam.Node_Manager_Role_Arn 
  private_subnet_Ids = module.dev_vpc.private_subnets
}

data "aws_eks_cluster_auth" "devcluster" {
  name = module.dev_cluster.cluster_name
}

# Allow provider to be passed from caller
provider "kubernetes" {
  alias = "this"
  host                   = module.dev_cluster.cluster_endpoint
  cluster_ca_certificate = module.dev_cluster.clustercertificate
  token                  = data.aws_eks_cluster_auth.devcluster.token
}

module "auth" {
  depends_on = [ module.dev_cluster ]

  source          = "../../modules/security/auth"
  eksclustername  = module.dev_cluster.cluster_name
  noderolearn     = module.iam.Node_Manager_Role_Arn 
  hosturl         = module.dev_cluster.cluster_endpoint

  providers = {
    kubernetes = kubernetes.this
  }  
}

module "certs" {
  depends_on = [ module.dev_cluster, module.auth ]

  source = "../../modules/security/certs"
  security-groups     = module.dev_vpc.eks_security_group_id
  private_cidr_block  = module.dev_vpc.private_cidr
  public_cidr_block   = module.dev_vpc.public_cidr
  eks_subnets         = module.dev_vpc.public_subnets
  securitygroupId     = module.dev_vpc.eks_security_group_id
  cluster_vpc_id      = module.dev_vpc.eks_vpc_id
  eksclustername      = module.dev_cluster.cluster_name
}

module "route53" {
  depends_on = [ module.certs ]
  source = "../../modules/dns/route53"
  private_cidr_block = module.dev_vpc.private_cidr
  public_cidr_block  = module.dev_vpc.public_cidr
  securitygroupId    = module.dev_vpc.eks_security_group_id
  ekscertificate     = module.certs.ekscertificate
  certarn            = module.certs.cert_arn 
}

module "rds_appdata" {
  source = "../../modules/database/rds"
}
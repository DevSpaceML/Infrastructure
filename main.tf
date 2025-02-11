#EKS_Deployment

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.defaultregion
}

module "clustervpc" {
	source = "./modules/clustervpc"
   name = "EksClusterVPC"
}

module "ekscluster" {
  source = "./modules/ekscluster"

  vpcId       = module.clustervpc.eks_vpc_id
  subnetIDs   = module.clustervpc.subnet_id_list
  public_cidr = module.clustervpc.public_cidr
  noderolearn = module.iam.node_manager_role_arn
}

module "iam" {
  source         = "./modules/iam"
  eksclustername = module.ekscluster.cluster_name
  vpc_id         = module.clustervpc.eks_vpc_id
}

module "applicationLB" {
 source          = "./modules/alb"
 security-groups = module.clustervpc.eks_security_group_id
 eks_subnets     = module.clustervpc.public_subnet
 securitygroupId = module.clustervpc.eks_security_group_id
 cluster_vpc_id  = module.clustervpc.eks_vpc_id
 eksclustername = module.clustervpc.cluster_name 
}




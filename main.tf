#EKS_Deployment

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.defaultregion
}

module "clustervpc" {
	source = "./modules/clustervpc"
}

/*
module "ekscluster" {
  source = "./modules/ekscluster"

  vpcId = module.clustervpc.eks_vpc_id
  subnetIDs = module.clustervpc.subnet_id_list

}

module "applicationLB" {
 source = "./modules/alb"
 security-groups = module.clustervpc.eks_security_group_id
 subnetIDs = module.clustervpc.subnet_id_list
 securitygroupId = module.clustervpc.eks_security_group_id
}




module "database" {
  source ="/opt/homebrew/var/terraform/modules/rds"
}

module "keymgmtsrvc" {
	source = "/"
}

*/


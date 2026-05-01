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
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "dev_vpc" {
  source                             = "../../../modules/network/vpc"
  cidr                               = var.dev_cidr
  vpcname                            = var.vpcname
  region                             = var.region
  createvpc = var.createvpc
  existing_vpc_id                    = var.existing_vpc_id
  public_subnet_cidr_blocks          = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks         = var.private_subnet_cidr_blocks
  nodegroup_pvt_subnet_cidr_blocks   = var.nodegroup_pvt_subnet_cidr_blocks
  rds_private_subnet_cidr_blocks     = var.rds_private_subnet_cidr_blocks
  clustername                        = var.clustername
}
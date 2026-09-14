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

module "cluster_vpc" {
  source                             = "../../../../modules/network/eks/vpc"
  cidr                               = var.cluster_cidr
  vpcname                            = var.vpcname
  region                             = var.region
  createvpc                          = var.createvpc
  vpc_id                             = var.vpc_id
  clustername                        = var.clustername
}
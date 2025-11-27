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

module "dev_cluster" {
  source            = "../../../modules/compute/eks/cluster"
  clustername       = var.clustername
  vpcId             = data.terraform_remote_state.dev_network.outputs.vpc_id
  subnetIdlist      = data.terraform_remote_state.dev_network.outputs.nodegroup_subnet_id_list
  public_subnet_ids = data.terraform_remote_state.dev_network.outputs.public_subnets
  private_subnet_ids = data.terraform_remote_state.dev_network.outputs.private_subnets
  public_cidr        = data.terraform_remote_state.dev_network.outputs.public_cidr
  cluster_role_arn   = data.terraform_remote_state.dev_iam.outputs.cluster_role_arn
  access_entries     = data.terraform_remote_state.dev_iam.outputs.access_entries
}
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


provider "kubernetes" {
   host = module.dev_cluster.cluster_endpoint
   cluster_ca_certificate = module.dev_cluster.cluster_cert
   
   exec {
	 api_version = "client.authentication.k8s.io/v1beta1"
	 command = "aws"
	 args = [
      "eks", "get-token",
      "--cluster-name", module.dev_cluster.cluster_name,
      "--region",       var.region
    ]
   }
}

module "dev_cluster" {
  source                 = "../../../modules/compute/eks/cluster"
  clustername            = var.clustername
  vpcId                  = data.terraform_remote_state.dev_network.outputs.vpc_id
  public_subnet_ids      = data.terraform_remote_state.dev_network.outputs.public_subnet_id_list
  private_subnet_ids     = data.terraform_remote_state.dev_network.outputs.private_subnet_id_list
  public_cidr            = data.terraform_remote_state.dev_network.outputs.public_cidr
  cluster_role_arn       = data.terraform_remote_state.dev_iam.outputs.cluster-role-arn
  node_role_arn          = data.terraform_remote_state.dev_iam.outputs.node-mgr-arn
  access_entries         = data.terraform_remote_state.dev_iam.outputs.access-entries-map
  region                 = data.terraform_remote_state.dev_network.outputs.region
}

module "eks_security_groups" {
  depends_on            = [ module.dev_cluster ]
  source                = "../../../modules/network/eks-security-groups"
  vpc_id                = data.terraform_remote_state.dev_network.outputs.vpc_id
  nodegroup_cidr_blocks = data.terraform_remote_state.dev_network.outputs.nodegroup_cidr
  clustername           = module.dev_cluster.cluster_name
}
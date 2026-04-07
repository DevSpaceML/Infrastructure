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

data "aws_eks_cluster_auth" "dev_cluster" {
  name = module.dev_cluster.cluster_name
}

provider "kubernetes" {
   host = module.dev_cluster.cluster_endpoint
   cluster_ca_certificate = base64decode(module.dev_cluster.certificate_authority[0].data)

   exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.dev_cluster.outputs.cluster_name, "--region", data.terraform_remote_state.dev_network.outputs.region]
  }
}

module "dev_cluster" {
  source                 = "../../../modules/compute/eks/cluster"
  clustername            = var.clustername
  region                 = data.terraform_remote_state.dev_network.outputs.region
  vpcId                  = data.terraform_remote_state.dev_network.outputs.vpc_id
  public_subnet_ids      = data.terraform_remote_state.dev_network.outputs.public_subnet_id_list
  private_subnet_ids     = data.terraform_remote_state.dev_network.outputs.private_subnet_id_list
  public_cidr            = data.terraform_remote_state.dev_network.outputs.public_cidr
  cluster_role_arn       = data.terraform_remote_state.dev_iam.outputs.cluster-role-arn
  node_role_arn          = data.terraform_remote_state.dev_iam.outputs.node-mgr-arn
  devops_admin_arn       = data.terraform_remote_state.dev_iam.outputs.DevOpsAdminSre-arn
  access_entries         = merge(data.terraform_remote_state.dev_iam.outputs.access-entries-map, {
                                  "github_actions" = {
                                     principal_arn     = data.terraform_remote_state.dev_iam.outputs.github-actions-arn
                                     type              = "STANDARD"
                                     kubernetes_groups = []
                                     user_name         = "github-actions"
                                    },
                                    "devops_admin" = {
                                      principal_arn = data.terraform_remote_state.dev_iam.outputs.DevOpsAdminSre-arn
                                      type = "STANDARD"
                                      kubernetes_groups = [cluster-admin]
                                      user_name = "devops-admin"
                                    },
                                    "node_manager" = {
                                      principal_arn = data.terraform_remote_state.dev_iam.outputs.node-mgr-arn
                                      type = "STANDARD"
                                      kubernetes_groups = []
                                      user_name = ""
                                    }
                              })
}

module "eks_security_groups" {
  depends_on            = [ module.dev_cluster ]
  source                = "../../../modules/network/eks-security-groups"
  vpc_id                = data.terraform_remote_state.dev_network.outputs.vpc_id
  nodegroup_cidr_blocks = data.terraform_remote_state.dev_network.outputs.nodegroup_cidr
  clustername           = module.dev_cluster.cluster_name
}
terraform {
  required_providers {
    aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
      }
      cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.26.0"
    }
  }
}

provider "cloudflare" {}

module "ephmrl_routing" {
  source      = "../../../../modules/alb/dev/routing"
  alb_arn     = var.alb_arn
  alb_name    = data.terraform_remote_state.eks_alb.outputs.alb_name
  vpc_id      = data.terraform_remote_state.cluster_network.outputs.vpc_id
  projectname = data.terraform_remote_state.eks_cluster.outputs.projectname
  clustername = data.terraform_remote_state.eks_cluster.outputs.cluster_name
  alb_securitygroup_id = data.terraform_remote_state.cluster_network.outputs.eks_sec_group_id
}
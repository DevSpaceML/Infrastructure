# App Deployment - Application-specific resources and configurations
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

locals {
  cluster = data.terraform_remote_state.cluster.outputs
  network = data.terraform_remote_state.network.outputs
}

module "ephmrl_routing" {
  source               = "../../../../modules/alb/dev/routing/shared-edge"
  alb_arn              = var.alb_arn
  alb_name             = local.cluster.alb_name
  certificate_arn      = local.cluster.acm_cert_arn
  vpc_id               = local.network.vpc_id
  projectname          = local.cluster.projectname
  clustername          = local.cluster.cluster_name
  alb_securitygroup_id = local.cluster.alb_sec_group_id
}


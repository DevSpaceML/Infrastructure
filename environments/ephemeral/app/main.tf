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
  alb     = data.terraform_remote_state.alb.outputs
}

module "cloudflare_dns" {
  source = "../../../modules/dns/cloudflare-wildcard"

  apexdomain        = var.apexdomain
  environment       = var.environment
  alb_dns           = local.alb.alb_dns_name
  manage_apex       = var.manage_apex
}

module "ephmrl_routing" {
  source               = "../../../modules/alb/routing/shared-edge"
  environment          = var.environment
  appdomain            = var.apexdomain
  alb_name             = local.alb.alb_name
  alb_arn              = local.alb.alb_arn
  certificate_arn      = local.alb.acm_cert_arn
  vpc_id               = local.cluster.vpc_id
  projectname          = local.cluster.projectname
  clustername          = local.cluster.cluster_name
  alb_securitygroup_id = local.cluster.alb_securitygroup_id
}
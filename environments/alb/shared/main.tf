terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.21"
    }
  }
}

provider "cloudflare" {}

module "shared-k8-alb" {
  source               = "../../../modules/alb/shared-k8-alb"
  alb_securitygroup_id = data.terraform_remote_state.cluster.outputs.alb_securitygroup_id
  public_subnet_ids    = data.terraform_remote_state.cluster.outputs.public_subnet_id_list
}

module "alb-certs" {
  source = "../../../modules/security/certs/alb-certs"
}
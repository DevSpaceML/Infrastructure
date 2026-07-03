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


module "dev_network" {
  source = "../../../../modules/network/dev"
}

module "dev_certs" {
  source = "../../../../modules/security/certs/alb-certs"
  alb_dns_name = module.dev_network.dev_alb_dns_name
  appdomain = var.appdomain
}


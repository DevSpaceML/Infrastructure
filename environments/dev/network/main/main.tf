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
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = ">= 5.21"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "cloudflare" {}

module "dev_network" {
  source = "../../../../modules/network/dev"
}



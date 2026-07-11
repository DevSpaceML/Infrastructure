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
  depends_on = [module.dev_network]
  source = "../../../../modules/security/certs/alb-certs"
}

module "dev_cert_validation" {
  depends_on = [module.dev_certs]
  source     = "../../../../modules/dns/cloudflare-cert-validation"

  cert_validation_options = module.dev_certs.dev_acm_cert_validation_options
  domain_names            = module.dev_certs.domain_names
  cert_arn                = module.dev_certs.dev_acm_cert_arn
}

module "dev-alb" {
  depends_on = [module.dev_cert_validation, module.dev_certs, module.dev_network ]

  source   = "../../../../modules/alb/dev"
  cert_arn = module.dev_certs.dev_acm_cert_arn
  alb_sg_id = module.dev_network.alb_security_group_id
  vpc_id = module.dev_network.dev_vpc_id
  domain_name = module.dev_certs.appdomain
  public_dev_subnet_list = module.dev_network.public_subnet_id_list
}

module "dev_dns" {
  depends_on = [module.dev-alb, module.dev_certs, module.dev_cert_validation]

  source = "../../../../modules/dns/cloudflare-dev-main"
  alb_dns_name = module.dev-alb.dev_alb_dns_name
  cert_arn     = module.dev_certs.dev_acm_cert_arn
  domain_names = module.dev_certs.domain_names
}

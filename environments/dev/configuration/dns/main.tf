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

module "dev_dns" {
  source = "../../../../modules/dns/cloudflare-dev-main"
  alb_dns_name = data.terraform_remote_state.dev_alb.outputs.dev_alb_dns_name
  cert_arn     = data.terraform_remote_state.dev_certs.outputs.dev_acm_cert_arn
  domain_names = data.terraform_remote_state.dev_certs.outputs.domain_names
}
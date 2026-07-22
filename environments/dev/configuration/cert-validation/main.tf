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

module "dev_cert_validation" {
  source     = "../../../../modules/dns/cloudflare-cert-validation"

  cert_validation_options  = data.terraform_remote_state.dev_certs.outputs.dev_acm_cert_validation_options
  domain_names             = data.terraform_remote_state.dev_certs.outputs.domain_names
  cert_arn                 = data.terraform_remote_state.dev_certs.outputs.dev_acm_cert_arn
  appdomain                = data.terraform_remote_state.dev_certs.outputs.appdomain
}
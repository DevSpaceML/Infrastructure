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


module "cloudflare_dns" {
  source = "../../modules/dns/cloudflare-corp"
  projectname  = var.projectname
  environment  = var.environment
  appdomain    = var.appdomain
  alb_dns_name = var.alb_dns_name
}
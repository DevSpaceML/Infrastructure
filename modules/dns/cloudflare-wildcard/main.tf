terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.26"
    }
  }
}

locals {
  env_domain = var.environment == "Prod" ? var.root_domain : "${var.environment}.${var.root_domain}"
}

data "cloudflare_zone" "main" {
  name = var.root_domain
}

resource "cloudflare_dns_record" "wildcard" {
  zone_id = data.cloudflare_zone.main.id
  name    = "*.${local.env_domain}"
  type    = "CNAME"
  content = var.cluster_alb_dns
  ttl     = 300
}
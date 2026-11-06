terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.26"
    }
  }
}

locals {
  env_domain = var.environment == "Prod" ? var.apexdomain : "${var.environment}.${var.apexdomain}"
  env_names  = toset([local.env_domain, "*.${local.env_domain}"])
}

data "cloudflare_zone" "apex" {
  filter = {
    name = var.apexdomain
  }
}

resource "cloudflare_dns_record" "apex" {
  count   = var.manage_apex ? 1 : 0

  zone_id = data.cloudflare_zone.apex.id
  name    = var.apexdomain
  type    = "CNAME"
  content = var.alb_dns
  ttl     = 300
}

resource "cloudflare_dns_record" "wildcard" {
  for_each = local.env_names

  zone_id = data.cloudflare_zone.apex.id
  name    = each.value
  type    = "CNAME"
  content = var.alb_dns
  ttl     = 300
}
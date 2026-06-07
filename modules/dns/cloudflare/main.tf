terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

data "cloudflare_zone" "main" {
  name = var.root_domain  # "salientapps.com"
}

resource "cloudflare_dns_record" "main" {
  for_each = var.persistent_domains

  zone_id = cloudflare_zone.main.id
  name    = each.value
  type    = "CNAME"
  content = var.aws_alb_dns 
  ttl     = 300
}

resource "cloudflare_dns_record" "wildcard" {
  zone_id = data.cloudflare_zone.main.id
  name    = "*.ephemeral.salientapps.com"
  type    = "CNAME"
  content = var.cluster_alb_dns
  ttl     = 300
}
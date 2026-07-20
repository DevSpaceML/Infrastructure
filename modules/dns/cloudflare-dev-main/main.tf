terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.21"
    }
  }
}


data "cloudflare_zone" "this" {
  filter = {
    name = var.appdomain
  }
}

resource "cloudflare_api_token" "dns_update" {
  name = "dns-update-token"
  policies = [{
    permission_groups = [
      { id = "4755a26eedb94da69e1066d98aa820be"  }
    ]
    resources = jsonencode({
      "com.cloudflare.api.account.zone.${data.cloudflare_zone.this.zone_id}" = "*"
    })
    effect = "allow"
  }]
}

resource "cloudflare_dns_record" "this" {
  zone_id = data.cloudflare_zone.this.id
  name    = var.appdomain
  type    = "CNAME"
  content = var.alb_dns_name
  ttl     = 3600
  proxied = false
}

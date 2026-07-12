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
      { id = "d755e40fc5815ba85a23bb7c45a6a66b"  }
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

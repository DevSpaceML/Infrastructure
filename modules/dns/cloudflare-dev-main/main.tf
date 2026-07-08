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

locals {
  cert_validation_map = {
    for dvo in var.cert_validation_options : dvo.domain_name => dvo
  }
}

resource "cloudflare_dns_record" "acm_cert_validation" {
  for_each = toset(var.domain_names)

  zone_id = data.cloudflare_zone.this.id
  name = local.cert_validation_map[each.value].resource_record_name
  type = local.cert_validation_map[each.value].resource_record_type
  content = local.cert_validation_map[each.value].resource_record_value
  ttl = 300
  proxied = false
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn = var.cert_arn
  validation_record_fqdns = [for record in cloudflare_dns_record.acm_cert_validation : record.name]
}
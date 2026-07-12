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

locals {
  cert_validation_map = {
    for dvo in var.cert_validation_options : dvo.resource_record_name => dvo...
  }
}

resource "cloudflare_dns_record" "acm_cert_validation" {
  for_each = local.cert_validation_map

  zone_id = data.cloudflare_zone.this.id
  name = each.value[0].resource_record_name
  type = each.value[0].resource_record_type
  content = each.value[0].resource_record_value
  ttl = 300
  proxied = false
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn = var.cert_arn
  validation_record_fqdns = [for record in cloudflare_dns_record.acm_cert_validation : record.name]
}
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
  domain_group_key = {
    for dvo in var.cert_validation_options :
    dvo.domain_name => trimprefix(dvo.domain_name, "*.")
  }

  domain_groups = {
    for domain, key in local.domain_group_key : key => domain...
  }

  cert_validations = {
    for key, domains in local.domain_groups :
    key => [for dvo in var.cert_validation_options : dvo if dvo.domain_name == (contains(domains, key) ? key : domains[0])][0]
  }
}

resource "cloudflare_dns_record" "acm_cert_validation" {
  for_each = local.cert_validations

  zone_id = data.cloudflare_zone.this.id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  content = each.value.resource_record_value
  ttl     = 300
  proxied = false
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn = var.cert_arn
  validation_record_fqdns = [for dvo in local.cert_validations: dvo.resource_record_name]

  depends_on = [cloudflare_dns_record.acm_cert_validation]
}
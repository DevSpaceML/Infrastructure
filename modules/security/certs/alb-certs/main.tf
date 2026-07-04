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

resource "aws_acm_certificate" "this" {
	domain_name               = var.appdomain
	validation_method         = "DNS"
	subject_alternative_names = ["*.${var.appdomain}"]

	options {
    certificate_transparency_logging_preference = "ENABLED"
   }	

	lifecycle {
     create_before_destroy = true
    }

	tags = {
		CertApplication = var.target
	}
}

locals {
  domain_validation_options = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.resource_record_name => {
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
}

resource "cloudflare_dns_record" "acm_cert_validation" {
  for_each = {
    for name, record in local.domain_validation_options : name => record[0]
  }

  zone_id = data.cloudflare_zone.this.id
  name = each.key
  type = each.value.type
  content = each.value.content
  ttl = 300
  proxied = false
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in cloudflare_dns_record.acm_cert_validation : record.name]
}
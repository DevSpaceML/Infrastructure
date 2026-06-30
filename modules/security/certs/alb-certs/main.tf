terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.21"
    }
  }
}

provider "cloudflare" {
  api_token = var.api-token
}

data "cloudflare_zone" "this" {
  filter = {
    name = var.appdomain
  }
}

data "cloudflare_account_api_token_permission_groups" "all" {}  

resource "cloudflare_api_token" "dns_update" {
  name = "dns-update-token"
  policies = [{
    permission_groups = [
      { id = data.cloudflare_api_token_permission_groups.all.zone["DNS Write"] }
    ]
    resources = {
      "com.cloudflare.api.account.zone.${data.cloudflare_zone.this.zone_id}" = "*"
    }
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

resource "cloudflare_dns_record" "acm_cert_validation" {
  for_each = {
    for dvo in aws_aws_acm_certificate.this.domain_validation_options : dvo.domain_name => dvo 
  }

  zone_id = data.cloudflare_zone.this.id
  name = each.value.resource_record_name
  type = each.value.resource_record_type
  content = each.value.resource_record_value
  ttl = 300
  proxied = false
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in cloudflare_dns_record.acm_cert_validation : record.hostname]
}
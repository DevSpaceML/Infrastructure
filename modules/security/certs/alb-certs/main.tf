
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.26"
    }
  }
}

data "cloudflare_zone" "this" {
  filter = {
    name = var.appdomain
  }
}

locals {
  subject_alternative_names = ["*.${var.appdomain}"]
  domain_names = distinct(concat([var.appdomain], local.subject_alternative_names))
  
}

resource "aws_acm_certificate" "this" {
	domain_name               = var.appdomain
	validation_method         = "DNS"
	subject_alternative_names = local.subject_alternative_names

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

resource "cloudflare_record" "acm_cert_validation" {
    for_each = {
	  for dvo in aws_acaws_acm_certificate.this.domain_validation_options :
	    dvo.domain_name => { name = dvo.resource_record_name, value = resource_record_value} 
	}

	zone_id = data.cloudflare_zone.this.cloudflare_zone_id
	name    = each.value.name
	type    = CNAME
	content = trimsuffix(each.value.value, ".")
	ttl     = 60
	proxied = false
}

resource "aws_acm_certificate_validation" "this" {
     certificate_arn         = aws_acm_certificate.this.arn
	 validation_record_fqdns = [ for r in cloudflare_record.acm_cert_validation : r.hostname ]
}

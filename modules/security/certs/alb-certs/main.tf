
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



locals {
  domain_names = distinct(concat([var.appdomain], var.subj_alt_names))
  alternate_domain_names = var.subj_alt_names
}

resource "aws_acm_certificate" "this" {
	domain_name               = var.appdomain
	validation_method         = "DNS"
	subject_alternative_names = local.alternate_domain_names

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


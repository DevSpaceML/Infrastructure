#eks networking module. Creates route53 Zones, Creates certs and applies them
#security group rules
# Deploy Application LoadBalancer 

data "aws_eks_cluster" "ekscluster" {
  name = var.eksclustername
}

resource "aws_route53_zone" "approute" {
	name  = "gemmapp.com"
}

resource "aws_acm_certificate" "eks_certificate" {
  depends_on = [ aws_route53_zone.approute ]

	domain_name        = "gemmapp.com"
	validation_method  = "DNS"
	subject_alternative_names = []

	options {
    certificate_transparency_logging_preference = "ENABLED"
   }	

	lifecycle {
     create_before_destroy = true
    }

	tags = {
		DeployedToCluster = data.aws_eks_cluster.ekscluster.name
	}
}

# perform eks cert validation. ingress creation fails without cert validation

resource "aws_route53_record" "certvalidation_r53_record" {
	depends_on = [null_resource.Update_GoDaddyDNS]	
	for_each = {
	    for dvo in aws_acm_certificate.eks_certificate.domain_validation_options : dvo.domain_name => {
	      name   = dvo.resource_record_name
	      type   = dvo.resource_record_type
	      record = dvo.resource_record_value
	    }
   }
    
	 zone_id   = aws_route53_zone.approute.zone_id
	 name      =  each.value.name
    type      = each.value.type
    records   = [each.value.record]
    ttl       = 60

}

resource "aws_acm_certificate_validation" "cert_validation" {
  depends_on = [ aws_route53_record.certvalidation_r53_record ]  
	certificate_arn         = aws_acm_certificate.eks_certificate.arn
	validation_record_fqdns = [for record in aws_route53_record.certvalidation_r53_record : record.fqdn]
}

#eks networking module. Creates route53 Zones, Creates certs and applies them
#security group rules
# Deploy Application LoadBalancer 

data "aws_eks_cluster" "ekscluster" {
  name = var.eksclustername
}

resource "aws_route53_zone" "approute" {
	name  = "approute.me"
}

resource "aws_acm_certificate" "eks_certificate" {
  depends_on = [ aws_route53_zone.approute ]

	domain_name        = "approute.me"
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

#  Update cert_arn in ingress yaml
resource "null_resource" "apply_certinfo_yaml" {
    depends_on = [ aws_acm_certificate.eks_certificate ]

    provisioner "local-exec" {
      command = <<EOT
      set -euo pipefail
      set -v
	    echo "Available Certificates:"
	    aws acm list-certificates
      echo "Updating Yaml Cert Variables"
      /bin/bash /opt/homebrew/var/infrastructure/eks/bash/update_yaml_vars.sh
      exit 0 
      EOT
      interpreter = ["/bin/bash", "-c"]
    }
 }


# update DNS Records at GoDaddy. Required for Cert Validation
 resource "null_resource" "Update_GoDaddyDNS" {
  depends_on = [ null_resource.apply_certinfo_yaml ]

	provisioner "local-exec" {
      command = <<EOT
      echo "Connect to GoDaddy and update dns records. Waiting 3 mins"
      sleep 180
	    #/bin/bash /opt/homebrew/var/infrastructure/eks/bash/update_dns.sh
      exit 0
      EOT
      interpreter = ["/bin/bash", "-c"]
    } 
 }
 

# perform eks cert validation. ingress apply fails without cert validation

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
	name      = each.value.name
    type      = each.value.type
    records   = [each.value.record]
    ttl       = 60

}

resource "aws_acm_certificate_validation" "cert_validation" {
  depends_on = [ aws_route53_record.certvalidation_r53_record ]  
	certificate_arn         = aws_acm_certificate.eks_certificate.arn
	validation_record_fqdns = [for record in aws_route53_record.certvalidation_r53_record : record.fqdn]
}

# #Application loadbalancer installed by ingress yaml.data aws_lb in cert module dependent on loadbalancer being active.
 resource "null_resource" "apply_ingress_yaml" {
    depends_on = [ aws_acm_certificate_validation.cert_validation ]
    provisioner "local-exec" {
      command = <<EOT
      set -euo pipefail
      set -v
      echo "Applying Ingress and Application Yaml manifests"
      /usr/local/bin/kubectl apply -f /opt/homebrew/var/infrastructure/eks/yaml/deploy_eksapp.yaml
      echo "waiting for loadbalancer to be ready"
      sleep 60
      aws elbv2 describe-load-balancers
      EOT
      interpreter = ["/bin/bash", "-c"]
    }
 } 


#eks networking module.

data "kubernetes_ingress_v1" "lb_ingress" {
  metadata {
    name      = "analyticsapp-lbc-ingress"
    namespace = "default"
  }
}

data "aws_lb" "cluster_lb" {
  count = length(data.aws_lb.lbs.arn) > 0 ? 1 : 0
  arn   = data.aws_lb.lbs.arn
}

data "aws_lb" "lbs" {  
  tags = {
    "kubernetes.io/cluster/${var.eksclustername}" = "owned"
    "elbv2.k8s.aws/ingress-name"                = "analyticsapp-lbc-ingress"
  }
}

resource "aws_security_group" "alb-sg" {
	name = "alb-security-group"
	description = "Inbound web traffic"
	vpc_id = var.cluster_vpc_id

	ingress {
		from_port = 80
		to_port   = 80
		protocol  = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		from_port = 443
		to_port   = 443
		protocol  = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port = 0
		to_port   = 0
		protocol  = -1
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
		Name = "alb-security-group"
	}
}

resource "aws_acm_certificate" "eks_certificate" {	
	domain_name        = "approute.me"
	validation_method  = "DNS"

	lifecycle {
    create_before_destroy = true
   }

	tags = {
		Environment = "Dev"
	}

}

resource "aws_route53_zone" "approute" {
	name  = "approute.me"
}

resource "aws_route53_record" "cert_validation" {
	for_each = {
	    for dvo in aws_acm_certificate.eks_certificate.domain_validation_options : dvo.domain_name => {
	      name   = dvo.resource_record_name
	      type   = dvo.resource_record_type
	      record = dvo.resource_record_value
	    }
   }
    
	zone_id = aws_route53_zone.approute.zone_id
	name    = each.value.name
    type    = each.value.type
    records = [each.value.record]
    ttl     = 60	
}

resource "aws_acm_certificate_validation" "cert_validation" {
	certificate_arn         = aws_acm_certificate.eks_certificate.arn
	validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_route53_record" "approute-eks" {
	name    = "approute.me"
	type    = "A"
	zone_id = aws_route53_zone.approute.zone_id
	
	alias {
		name = data.kubernetes_ingress_v1.lb_ingress.status[0].load_balancer[0].ingress[0].hostname
		zone_id = data.aws_lb.cluster_lb[0].zone_id
		evaluate_target_health = true
	}
}
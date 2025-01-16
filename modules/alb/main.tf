#Application Load Balancer module.

resource "aws_security_group" "alb-sg" {
	name = alb-security-group
	description = "Inbound web traffic"
	vpc_id = var.vpc_id

	ingress {
		from_port = 443
		to_port   = 443
		protocol  = 'tcp'
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port = 0
		to_port   = 0
		protocol  = -1
		cidr_blocks = [0.0.0.0/0]
	}

	tags = {
		Name = "alb-security-group"
	}
}


resource "aws_acm_certificate" "eks_certificate" {
	
	domain_name = "app.tiyeni"
	validation_method  = "DNS"

	tags = {
		Environment = "Dev"
	}

}

resource "aws_route53_record" "cert_validation" {
	
	for_each = {
 		for dvo in aws_acm_certificate.eks_certificate.domain_validation_options :
 		dvo.domain_name => {
 			name   = dvo.resource_record_name
 			record = dvo.resource_record_value
 			type.  = dvo.resource_record_type
 		}

	}

	name    = each.value.name
	type    = each.value.type
	zone_id = aws_route53_zone.???.zone_id
	ttl.    = 300
}


resource "aws_lb" "web-application-lb" {
	name = "web-app-lb"
	internal = false
	load_balancer_type = "application"
	security_groups = [aws_security_group.alb-sg.id]
	subnets = var.subnetIDs 

	enable_deletion_protection = true

	tags = {
		Environment = "dev"
		Application = "Stock Analytics"
	}

}

resource "aws_lb_listener" "eks_https_listener" {
	load_balancer_arn = aws_lb.web-application-lb.arn
	port 			  = 443	
	protocol 		  = "HTTPS"

	ssl_policy 		  = "ELBSecurityPolicy-2016-08"
	certificate_arn   = "aws_acm_certificate.eks_certificate"

	default_action {
		type = "forward"
		target_group_arn = awl_lb_target_group.tiyeniapp_tg.arn

	}		
}


resource "aws_lb_target_group" "tiyeniapp_tg" {
	name 	 = "tiyeniapp-tg"
	port 	 = 80
	protocol = "HTTP"
	vpc_id 	 = aws_vpc.clustervpc.id


	health_check {
		path 			  = "??"
		interval 		  = 30
		timeout  		  = 5
		healthy_threshold = 3
		matcher.          = "200"
	}
	
}


























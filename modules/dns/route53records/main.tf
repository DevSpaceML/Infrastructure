
data "aws_lb" "eks-lb" {
  name = "${var.deployment}-eks-lb"
}

resource "aws_route53_record" "app-eks" {
	name    = var.deployment
	type    = "A"
	zone_id = var.zone_id
	
	alias {
		name = data.aws_lb.eks-lb.dns_name
		zone_id = data.aws_lb.eks-lb.zone_id
		evaluate_target_health = true
	}
}

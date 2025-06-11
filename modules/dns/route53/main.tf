# Create Hosted Zones for Application
#get lb data dynamically [change to use variables for tags]
data "aws_lb" "eks-lb" {    	
        name = "eks-cluster-lb"
} 

data "aws_route53_zone" "approute" {
	name  = "approute.me"
}

resource "aws_route53_record" "approute-eks" {
	name    = "approute.me"
	type    = "A"
	zone_id = data.aws_route53_zone.approute.zone_id
	
	alias {
		name = data.aws_lb.eks-lb.dns_name
		zone_id = data.aws_lb.eks-lb.zone_id
		evaluate_target_health = true
	}

}

# Create Security Groups
resource "aws_security_group_rule" "eks-tcp-ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = var.securitygroupId
  cidr_blocks       = var.public_cidr_block
}

resource "aws_security_group_rule" "node-group-egress" {
	type 			  = "egress"
	from_port         = 10250
	to_port   		  = 10250
	protocol  		  = "tcp"
	security_group_id = var.securitygroupId
	cidr_blocks		  = var.private_cidr_block	
}
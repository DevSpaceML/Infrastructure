# Create Hosted Zones for Application
#get lb data dynamically [change to use variables for tags]

data "aws_lb" "eks-lb" {    	
    name = "eks-cluster-lb"
} 

resource "aws_route53_zone" "internal" {
  count = var.environment == "dev" ? 1 : 0	
  name = "internal.${var.projectname}.dev"
}

resource "aws_route53_zone" "public" {
	count = var.environment == "dev" ? 0:1
	name  = "${var.projectname}.com"
}

locals {
	 deployment = var.environment == "dev" ? "internal.${var.projectname}.dev" : "${var.projectname}.com"
     zone_id = var.environment == "dev" ? one(aws_route53_zone.internal[*].zone_id) : one(aws_route53_zone.public[*].zone_id)
     zone_name = var.environment == "dev" ? one(aws_route53_zone.internal[*].name) : one(aws_route53_zone.public[*].name)
   }

resource "aws_route53_record" "app-eks" {
	name    = local.deployment
	type    = "A"
	zone_id = local.zone_id
	
	alias {
		name = data.aws_lb.eks-lb.dns_name
		zone_id = data.aws_lb.eks-lb.zone_id
		evaluate_target_health = true
	}
}


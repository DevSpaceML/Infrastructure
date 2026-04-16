# Create Hosted Zones for Application

resource "aws_route53_zone" "internal" {
  count = var.environment == "dev" ? 1 : 0	
  name = "internal.${lower(replace(var.projectname, " ", "-"))}.dev"
}

resource "aws_route53_zone" "public" {
	count = var.environment == "dev" ? 0:1
	name  = "${lower(replace(var.projectname, " ", "-"))}.com"
}

locals {
	 deployment = var.environment == "dev" ? "internal.${lower(replace(var.projectname, " ", "-"))}.dev" : "${lower(replace(var.projectname, " ", "-"))}.com"
     zone_id = var.environment == "dev" ? one(aws_route53_zone.internal[*].zone_id) : one(aws_route53_zone.public[*].zone_id)
     zone_name = var.environment == "dev" ? one(aws_route53_zone.internal[*].name) : one(aws_route53_zone.public[*].name)
	 zone_arn = var.environment == "dev" ? one(aws_route53_zone.internal[*].arn) : one(aws_route53_zone.public[*].arn)
   }

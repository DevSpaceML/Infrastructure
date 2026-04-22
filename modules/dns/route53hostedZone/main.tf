# Create Route53 Hosted Zones for Application
locals {
	  project_slug = lower(replace(var.projectname, " ", "-"))

    # use private dns only when explicitly requested
    use_private_dns = var.use_private_dns

    domain = local.use_private_dns ? "${local.project_slug}.internal" : "${local.project_slug}.${var.root_domain}"
    zone_id = local.use_private_dns ? aws_route53_zone.internal[0].id : aws_route53_zone.public[0].id
    zone_name = local.use_private_dns ? aws_route53_zone.internal[0].name : aws_route53_zone.public[0].name
    zone_arn = local.use_private_dns ? aws_route53_zone.internal[0].arn : aws_route53_zone.public[0].arn
  }

resource "aws_route53_zone" "internal" {
  count = local.use_private_dns	? 1 : 0
  name = local.domain
  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_zone" "public" {
	count = local.use_private_dns ? 0 : 1
	name  = local.domain
}

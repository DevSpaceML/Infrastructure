output "dev_alb_dns_name" {
  value = module.dev-alb.dev_alb_dns_name
}

output "dev_alb_arn" {
  value = module.dev-alb.dev_alb_arn
}

output "ecs_slfsvc_tg_arn" {
  description = "DEV Ecs self-service target group ARN"
  value = module.dev-alb.ecs_slfsvc_tg_arn
}
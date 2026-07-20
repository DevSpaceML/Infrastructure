output "dev_alb_dns_name" {
  value = module.dev-alb.dev_alb_dns_name
}

output "ecs_slfsvc_tg_arn" {
  description = "ARN for dev ECS self-service target group"
  value = module.dev-alb.ecs_slfsvc_tg_arn
}
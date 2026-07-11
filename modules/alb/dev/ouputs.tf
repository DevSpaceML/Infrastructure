output "dev_alb_dns_name" {
  description = "DNS name for dev ALB"
  value = aws_lb.dev_alb.dns_name
}

output "ecs-slfsvc-tg_arn" {
  description = "ARN of the AWS ALB target group"
  value       = aws_alb_target_group.ecs-slfsvc-tg.arn
}
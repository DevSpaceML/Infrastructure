output "alb_arn" {
  value = aws_lb.k8_shared.arn
}

output "alb_name" {
  value = aws_lb.k8_shared.name
}

output "alb_dns_name" {
  value = aws_lb.k8_shared.dns_name
}

output "alb_security_group_ids" {
  value = aws_lb.k8_shared.security_groups
}

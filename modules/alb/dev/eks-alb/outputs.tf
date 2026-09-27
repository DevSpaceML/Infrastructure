output "alb_arn" {
  value = aws_lb.k8_shared.arn
}

output "alb_name" {
  value = aws_lb.k8_shared.name
}
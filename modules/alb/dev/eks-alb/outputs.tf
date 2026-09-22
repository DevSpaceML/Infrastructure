output "tgtgrp_arn" {
  value = aws_lb_target_group.project.arn
}

output "alb_arn" {
  value = aws_lb.k8_shared.arn
}

output "alb_name" {
  value = aws_lb.k8_shared.name
}
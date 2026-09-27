output "tgtgrp_arn" {
  value = aws_lb_target_group.project.arn
}

output "cloudflare_dns_record" {
  value = cloudflare_dns_record.app.name 
}
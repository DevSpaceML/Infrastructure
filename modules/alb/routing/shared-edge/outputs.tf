output "tgtgrp_arn" {
  value = aws_lb_target_group.traefik.arn
}

output "hostname" { 
  value = local.fqdn 
}
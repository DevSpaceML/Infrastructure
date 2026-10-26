output "tgtgrp_arn" {
  value = aws_lb_target_group.project.arn
}

output "hostname" { 
  value = local.fqdn 
}

output "host_suffix" { 
  value = local.env_domain
}
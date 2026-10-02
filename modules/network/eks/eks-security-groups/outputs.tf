output "alb_sg_id" {
  value = aws_security_group.alb-sg.id
}

output "nodegroup_sg_id" {
  value = aws_security_group.nodegroup-sg.id
}

output "ctrl_plane_sg_id" {
  value = local.cluster_sg_id
}
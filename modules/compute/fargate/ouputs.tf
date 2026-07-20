output "ecs_exec_role_arn" {
  value = aws_iam_role.ecs_exec.arn
}

output "ecs_exec_role_name" {
  value = aws_iam_role.ecs_exec.name
}
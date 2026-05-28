output "amp_url" {
  value = aws_prometheus_workspace.this.workspace_url
}

output "amp_arn" {
  value = aws_prometheus_workspace.this.arn
}

output "amp_namespace" {
  value = aws_prometheus_workspace.this.alias
}

output "amp_workspace_id" {
  value = aws_prometheus_workspace.this.id
}

output "irsa_role_arn" {
  value = module.irsa_prometheus.iam_role_arn
}

output "prometheus_svc_acc" {
  value = kubernetes_svc_account_v1.prometheus_agent.metadata[0].name
}



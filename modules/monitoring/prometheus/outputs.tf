output "amp_url" {
  value = aws_prometheus_workspace.monitor.workspace_url
}

output "amp_arn" {
  value = aws_prometheus_workspace.monitor.arn
}

output "monitor_namespace" {
  value = aws_prometheus_workspace.monitor.alias
}

output "prometheus_svc_acc" {
  value = kubernetes_svc_account_v1.prometheus_agent.metadata[0].name
}
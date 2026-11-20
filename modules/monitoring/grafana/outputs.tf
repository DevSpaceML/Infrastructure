output "monitoring_url" {
  value = "https://${aws_grafana_workspace.this.endpoint}/d/${grafana_dashboard.k8_Overview.uid}/cluster-overview?orgId=1&var-cluster=${var.clustername}&from=now-1h&to=now&refresh=30s}"
}

output "grafana_endpoint" {
  value = aws_grafana_workspace.this.endpoint
}
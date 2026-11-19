output "monitoring_url" {
  value = "https://${var.grafana_endpoint/d/${grafana_dashboard.cluster_overview.uid}/cluster-overview?orgId=1&var-cluster=${var.clustername}&from=now-1h&to=now&refresh=30s}"
}
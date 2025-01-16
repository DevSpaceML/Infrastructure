
output "cluster_endpoint" {
  value = aws_eks_cluster.analytics.endpoint
}

output "node_group_arns" {
  value = aws_eks_node_group.analytics_nodes.arn
}
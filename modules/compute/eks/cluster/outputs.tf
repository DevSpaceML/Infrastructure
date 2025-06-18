
output "cluster_endpoint" {
  value = aws_eks_cluster.ekscluster.endpoint
}

output "cluster_name" {
  value = aws_eks_cluster.ekscluster.name
}

output "cluster_token" {
  value = aws_eks_cluster.ekscluster.identity[0].oidc[0].issuer
  description = "Authentication token for the EKS cluster"
  sensitive   = true  # Mark it as sensitive to avoid showing it in logs
}

output "clustercertificate" {
  value = base64decode(aws_eks_cluster.ekscluster.certificate_authority[0].data)
}

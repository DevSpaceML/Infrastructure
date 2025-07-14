
output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_token" {
  value = aws_eks_cluster.this.identity[0].oidc[0].issuer
  description = "Authentication token for the EKS cluster"
  sensitive   = true  # Mark it as sensitive to avoid showing it in logs
}

output "clustercertificate" {
  value = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
}

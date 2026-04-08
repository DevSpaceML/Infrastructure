terraform {
  required_version = ">= 1.4.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.36.0"
    }
  }
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = var.clustername
  addon_name   = "vpc-cni"
}


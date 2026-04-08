terraform {
  required_version = ">= 1.4.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.36.0"
    }
  }
}

resource "aws_eks_addon" "kube_proxy" {  
  cluster_name = var.clustername
  addon_name   = "kube-proxy"
}

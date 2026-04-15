terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.36.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
  }
}

resource "helm_release" "external-dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "7.3.0"

  set = [ 
    {
        name  = "provider"
        value = "aws"
    },
    {
        name  = "aws.region"
        value = "us-east-1"
    },
    {
        name  = "policy"
        value = "upsert-only"
    },

        {
        name  = "txtOwnerId"
        value = "my-cluster"
        },
    {
        name  = "domainFilters[0]"
        value = "example.com"
    },
    {
        name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
        value = var.externalDns_irsa
    }
  ]
}
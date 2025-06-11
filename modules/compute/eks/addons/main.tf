# Network Module, installs network components.
# IAM ROLES - IAM Roles for : LoadBalancer Controller,  
# SERVICE ACCOUNTS - Service Account for LoadBalancer Controller
# Helm Charts for loadBalancer Controller installation
# LoadBalancer Contoller, Wireless ApplicationFirewall

terraform {
  required_version = ">= 1.4.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.36.0"
    }
  }
}

data "aws_region" "current" {}

data "aws_eks_cluster" "eks-cluster" {
  name = var.clustername
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.clustername
}

resource "aws_eks_addon" "vpc_cni" {

  cluster_name = data.aws_eks_cluster.eks-cluster.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "coredns" {
  
  cluster_name = data.aws_eks_cluster.eks-cluster.name
  addon_name   = "coredns"
}

resource "aws_eks_addon" "kube_proxy" {
  
  cluster_name = data.aws_eks_cluster.eks-cluster.name
  addon_name   = "kube-proxy"
}


resource "aws_iam_openid_connect_provider" "eks_oidc_connect" {
  client_id_list = [ "sts.amazonaws.com" ]
  url = data.aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}

data "aws_iam_openid_connect_provider" "eks_oidc" {
  depends_on = [ aws_iam_openid_connect_provider.eks_oidc_connect ]
  url = data.aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_role" "lb_controller_role"{
    depends_on = [ aws_iam_openid_connect_provider.eks_oidc_connect ]
    name = "lbControllerRole"

    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Effect = "Allow"
            Principal = {
                Federated = aws_iam_openid_connect_provider.eks_oidc_connect.arn
            }
            Action = "sts:AssumeRoleWithWebIdentity"
            Condition = {
                StringEquals = {
                    "${replace(data.aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:svcacc-lbc"
                }
            }
       }]
    })  
}

resource "kubernetes_service_account" "svc_acc_lbController" {
  metadata {
    name        = "svcacc-lbc"
    namespace   = "kube-system"
    annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.lb_controller_role.arn
    }
  }
}

resource "aws_iam_policy" "lb_controller_policy" {
    name        = "lbControllerPolicy"
    description = "IAM policy for lbControllerRole"
    policy      = file("${path.module}/lbControllerPolicy.json")  
}

resource "aws_iam_role_policy_attachment" "attach_lbControllerPolicy" {
  role       = aws_iam_role.lb_controller_role.name
  policy_arn = aws_iam_policy.lb_controller_policy.arn
}


resource "helm_release" "aws_load_balancer_controller" {
  depends_on = [ kubernetes_service_account.svc_acc_lbController ]

  name       = "eks-cluster-lbc"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.7.1"

  set {
    name = "clusterName"
    value = data.aws_eks_cluster.eks-cluster.name
  }

  set {
    name = "serviceAccount.create"
    value = "false"
  }

  set {
    name = "serviceAccount.name"
    value = kubernetes_service_account.svc_acc_lbController.metadata[0].name
  }
}









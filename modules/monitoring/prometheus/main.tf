resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "aws_prometheus_workspace" "this" {
  alias = "${var.clustername}-monitoring"

  tags = {
    Environment = var.environment
    Cluster     = var.clustername
  }
}

locals {
  monitoring_namespace = "monitoring"
  prometheus_sa_name   = "prometheus-agent-svc-acc"
}

resource "aws_iam_policy" "amp_write_policy" {
  name        = "${var.clustername}-amp-policy"
  description = "IAM policy for Prometheus Agent to write to AMP workspace"

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "aps:RemoteWrite",
            "aps:GetSeries",
            "aps:GetLabels",
            "aps:GetMetricMetadata"
          ]
          Resource = aws_prometheus_workspace.this.arn
        },
      ]
    }
   )    
}

module "irsa_prometheus" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "6.8.1"
  name = join("-", [substr(var.clustername, 0, 10), "promagent-irsa"])
  oidc_providers = {
    main = {
      provider_arn = var.oidc_arn
      namespace_service_accounts = ["${local.monitoring_namespace}:${local.prometheus_sa_name}"]
    }
  }  
  policies = {
    amp_write_policy = aws_iam_policy.amp_write_policy.arn
  }
 
}

resource "kubernetes_service_account_v1" "prometheus" {
  metadata {
    name        = "prometheus-agent-svc-acc"
    namespace   = kubernetes_namespace_v1.monitoring.metadata[0].name
    annotations = {
        "eks.amazonaws.com/role-arn" = module.irsa_prometheus.arn
    }
  }
}

# Monitoring Role and RoleBinding
resource "kubernetes_cluster_role_v1" "k8monitor" {
  depends_on = [ terraform_data.verify_access ]

  metadata {
	name = "k8monitor"
  }

  rule {
	api_groups = [""]
	resources = ["nodes","nodes/metrics","nodes/stats","nodes/proxy","pods","services","endpoints"]
	verbs = ["get","list","watch"]
  }

  rule {
	api_groups = ["apps"]
	resources = ["deployments","statefulsets","daemonsets"]
	verbs = ["get","list","watch"]
  }

}

resource "kubernetes_cluster_role_binding_v1" "k8monitor_role_binding" {
	depends_on = [ kubernetes_cluster_role_v1.k8monitor ]
	metadata {
	  name = "k8monitor-binding"
	}

	role_ref {
	  api_group    = "rbac.authorization.k8s.io"
	  kind         = "Role"
	  name         = kubernetes_cluster_role_v1.prometheus.metadata[0].name
	}

	subject {
	  kind = "ServiceAccount"
	  name = kubernetes_service_account_v1.prometheus.metadata[0].name
    namespace = kubernetes_service_account_v1.prometheus.metadata[0].namespace
	}
}
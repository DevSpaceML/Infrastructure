resource "aws_prometheus_workspace" "this" {
  alias = "${var.clustername}-monitoring"

  tags = {
    Environment = var.environment
    Cluster     = var.clustername
  }
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
          Resource = aws_prometheus_workspace.monitor.arn
        },
      ]
    }
   )    
}

module "irsa_prometheus" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"
  role_name = "prometheusagent-irsa-${var.clustername }"
  oidc_providers = {
    provider_arn = var.oidc_arn
    main = {
      namespace = aws_prometheus_workspace.this.alias
      service_account_name = ["monitoring:prometheus-agent-svc-acc"]
    }
  role_policy_arns = {
    amp_write_policy = aws_iam_policy.amp_write_policy.arn
  }

 }
}

resource "kubernetes_svc_account_v1" "prometheus_agent" {
  metadata {
    name        = "prometheus-agent-svc-acc"
    namespace   = "monitoring"
    annotations = {
        "eks.amazonaws.com/role-arn" = module.irsa_prometheus.iam_role_arn
    }
  }
}  
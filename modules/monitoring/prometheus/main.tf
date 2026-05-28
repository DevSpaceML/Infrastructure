resource "aws_prometheus_workspace" "monitor" {
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

resource "kubernetes_svc_account_v1" "prometheus_agent" {
  metadata {
    name        = "prometheus-agent"
    namespace   = aws_prometheus_workspace.monitor.alias
    annotations = {
        "eks.amazonaws.com/role-arn" = module.irsa_prometheus.iam_role_arn
    }
  }
}  
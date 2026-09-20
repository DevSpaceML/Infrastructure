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
      namespace_service_accounts = ["monitoring:prometheus-agent-svc-acc"]
    }
  }  
  policies = {
    amp_write_policy = aws_iam_policy.amp_write_policy.arn
  }
 
}

resource "kubernetes_service_account_v1" "prometheus_agent" {
  metadata {
    name        = "prometheus-agent-svc-acc"
    namespace   = "monitoring"
    annotations = {
        "eks.amazonaws.com/role-arn" = module.irsa_prometheus.arn
    }
  }
}
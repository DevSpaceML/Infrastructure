# Grafana Data source
terraform {
  required_version = ">= 1.4.0"
  required_providers {  
    grafana = {
      source = "grafana/grafana"
      version = "~> 4.0"
    }
  }  
}

data "aws_region" "current" {}

resource "grafana_workspace" "this" {
  name = "salient-${var.env}"
  account_access_type = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"]
  permission_type = ["SERVICE_MANAGED"]
  data_sources = ["PROMETHEUS"]
  grafana_version = "10.4"
}

data "aws_ssoadmin_instances" "this" {}

locals {
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  grafana_viewers   = "grafana-viewers"
}

data "aws_identitystore_group" "gf_viewers" {
  identity_store_id = local.identity_store_id
  alternate_identifier {
    unique_attribute {
      attribute_path = "DisplayName"
      attribute_value = local.grafana_viewers
    }
  }
}

resource "aws_grafana_role_association" "viewers" {
  workspace_id = aws_grafana_workspace.this.id
  role = "VIEWER"
  group_ids = [data.aws_identitystore_group.gf_viewers.group_id]
}

resource "aws_grafana_role_association" "gf_admins" {
  workspace_id = aws_grafana_workspace.this.id
  role = "ADMIN"
  user_ids = [var.admin_sso_user_id]
}

resource "grafana_data_source" "grafana" {
  type = "prometheus"
  name = "amp-${var.env}"
  uid  = "amp-${var.env}"
  url  = var.prometheus_workspace_url
  json_data_encoded = jsonencode({
    httpMethod    = "POST"
    sigV4Auth     = true
    sigV4AuthType = "default"
    sigV4Region   = data.aws_region.current.region
  })
}

resource "grafana_folder" "k8monitor" {
  title = "k8monitor"
}

resource "grafana_dashboard" "k8 Overview" {
  folder = grafana_folder.k8monitor.id
  config_json = file("${path.module}/dashboards/cluster_overview.json")
}



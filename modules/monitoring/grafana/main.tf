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

resource "grafana_data_source" "grafana" {
  type = "prometheus"
  name = "amp-${var.clustername}"
  url  = var.prometheus_workspace_url
  json_data_encoded = jsonencode({
    httpMETHOD    = "POST"
    sigV4Auth     = true
    sigV4AuthType = "default"
    sigV4Region   = data.aws_region.current.region
  })
}
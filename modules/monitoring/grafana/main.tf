# Grafana Data source

data "aws_region" "current" {}

resource "grafana_data_source" "grafana" {
  type = "prometheus"
  name = "amp-${var.clustername}"
  url  = var.prometheus_workspace_url
  json_data_encoded = json_encode({
    httpMETHOD    = "POST"
    sigV4Auth     = true
    sigV4AuthType = "default"
    sigV4Region   = data.aws_region.current.region
  })
}
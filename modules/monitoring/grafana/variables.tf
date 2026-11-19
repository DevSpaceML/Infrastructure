
variable "clustername" {
  description = "deployed cluster name"
  type = string
}

variable "env" {
  description = "deployment environment"
  type        = string
}

variable "prometheus_workspace_url" {
  description = "Endpoint url for the amp workspace"
  type        = string 
}

variable "grafana_endpoint" {
  description = "grafana endpoint"
  type        = string
}

variable "grafana_viewers_group" {
  description = "users/roles that can view grafana"
  type        = string
}

variable "admin_sso_user_id" {
  description = "id of admin user"
  type = string
}
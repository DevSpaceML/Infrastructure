
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

variable "devops_user" {
  description = "name of the devops admin/account or role"
  type        = string
  default     = "SteveB_Devops"  
}

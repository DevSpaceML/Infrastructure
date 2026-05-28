variable "clustername" {
  description = "name of deployed cluster"
  type = string
}

variable "environment" {
  description = "deployment environment"
  type = string
}

variable "oidc_arn" {
  description = "oidc arn"
  type = string
}
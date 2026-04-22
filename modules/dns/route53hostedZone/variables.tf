variable "projectname" {
  description = "Name of application"
  type = string
}

variable "root_domain" {
  description = "Root domain for public hosted zone"
  type = string
}

variable "environment" {
  description = "Deployment environment"
  type = string
}

variable "use_private_dns" {
  description = "boolean user choice"
  type = bool
  default = false
}

variable "vpc_id" {
  description = "ID of the VPC for private hosted zone"
  type = string
}


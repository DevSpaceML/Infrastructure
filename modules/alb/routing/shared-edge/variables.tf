variable "environment" {
  description = "EKS environment"
  type = string
  default = ""
}

variable "projectname" {
  description = "EKS project name"
  type = string
  default = ""
}

variable "projinstance_id" {
  description = "EKS project instance. e.g pull request id"
  type = string
  default = ""
}

variable "appdomain" {
  description = "app domain"
  type = string
  default = "salientapps.com"
}

variable "create_vpc" {
  description = "Dedicated vpc for cluster"
  type = bool
  default = false
}

variable "vpc_id" {
  description = "vpc project will deploy to"
  type = string
}

variable "alb_name" {
  description = "alb name"
  type = string
}

variable "alb_arn" {
  description = "Arn of k8 alb"
  type = string
}

variable "alb_securitygroup_id" {
  description = "ID of the security group for the ALB"
  type = string

}

variable "traefik_port" {
  description = "Port for traefik"
  type = number
  default = 8080
}

variable "traefik_health_port" {
  description = "Port for traefik health check"
  type = number
  default = 8080
}

variable "clustername" {
  description = "Name of cluster"
  type        = string
}

variable "certificate_arn" {
  description = "Arn of the alb certificate"
  type = string
}
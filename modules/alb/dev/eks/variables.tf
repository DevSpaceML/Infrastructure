variable "projectname" {
  description = "EKS project name"
  type = string
  default = ""
}

variable "vpc_id" {
  description = "vpc project will deploy to"
  type = string
}

variable "alb_arn" {
  description = "arn of loadbalancer controller"
  type = string
}

variable "clustername" {
	description = "Name of cluster to be provisioned"
	type = string
}
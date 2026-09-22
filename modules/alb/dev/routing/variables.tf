variable "projectname" {
  description = "EKS project name"
  type = string
  default = ""
}

variable "vpc_id" {
  description = "vpc project will deploy to"
  type = string
}

variable "alb_securitygroup_id" {
  description = "ID of the security group for the ALB"
  type = string

}

variable "clustername" {
  description = "Name of cluster"
  type        = string
}

variable "alb_arn" {
  description = "Arn of k8 alb"
  type = string
}

variable "alb_name" {
  description = "alb name"
  type = string
}
variable "vpc_id" {
  description = "ID of the vpc the security group belongs to"
  type = string
}

variable "clustername" {
  description = "Name of the EKS cluster"
  type = string
}

variable "environment" {
  description = "Deployment Environment"
  type = string
  default = "dev"
}

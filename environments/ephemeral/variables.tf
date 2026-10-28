variable "clustername" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "region" {
  description = "The AWS region for the EKS cluster"
  type        = string
}

variable "instancetype" {
  description = "The EC2 instance type for the node group"
  type        = string
}
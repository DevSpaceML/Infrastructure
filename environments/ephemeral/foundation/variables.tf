variable "cidr" {
  description = "cidr of the VPC"
  type = string
}

variable "vpcname" {
  description = "The name of the VPC"
  type        = string
}

variable "createvpc" {
  description = "Whether to create a new VPC"
  type        = bool
}

variable "vpc_id" {
  description = "The ID of the VPC to use if not creating a new one"
  type        = string
}

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
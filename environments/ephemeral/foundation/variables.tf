variable "cidr" {
  description = "cidr of the VPC"
  type = string
  default = "10.0.0.0/16"
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
  default     = "dev"
}

variable "region" {
  description = "The AWS region for the EKS cluster"
  type        = string
  default     = "us-east-1"
}

variable "instancetype" {
  description = "The EC2 instance type for the node group"
  type        = string
  default     = "t4g.small"
}
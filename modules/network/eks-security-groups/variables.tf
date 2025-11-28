variable "vpc_id" {
  description = "ID of the vpc the security group belongs to"
  type = string
}

variable "clustername" {
  description = "Name of the EKS cluster"
  type = string
}

variable "nodegroup_cidr_blocks" {
  description = "Cidr blocks containing worker nodes"
  type = list(string)
}
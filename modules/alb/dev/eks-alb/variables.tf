variable "public_subnet_ids" {
  description = "List of public subnets"
  type = list
  default = []
}

variable "eks_securitygroup_id" {
  description = "ID of the security group for the ALB"
  type = string
}
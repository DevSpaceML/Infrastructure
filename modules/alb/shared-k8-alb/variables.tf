variable "public_subnet_ids" {
  description = "List of public subnets"
  type = list
  default = []
}

variable "alb_securitygroup_id" {
  description = "ID of the security group for the ALB"
  type = string
}

variable "environment" {
  description = "Name of the ALB"
  type = string
  default = "dev"
}
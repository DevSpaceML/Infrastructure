variable "clustername" {
	description = "Name of cluster to be provisioned"
	type = string
}

variable "var.public_subnet_ids" {
  description = "List of public subnets"
  type = list
  default = []
}

variable "alb_securitygroup_id" {
  description = "ID of the security group for the ALB"
  type = string

}
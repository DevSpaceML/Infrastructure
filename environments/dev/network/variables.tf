
variable "dev_cidr" {
  description = "Default cidr block for VPC cluster"
  type        = string
}

variable "region" {
  description = "aws region"
  type        = string
}

variable "vpcname" {
  description = "name of vpc used by dev cluster"
  type        = string
}

variable "createvpc" {
  description = "creates dedicated vpc if true"
  type = bool
}

variable "rds_private_subnet_cidr_blocks" {
    description = "list of cidr blocks for RDS instances"
	type = list(string)
	default = []
}

variable nodegroup_pvt_subnet_cidr_blocks {
	description = "list if cidr blocks for nodegroup private subnets"
	type = list(string)
	default = []
}

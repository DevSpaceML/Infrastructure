variable "clustername" {
  description = "name of the dev cluster"
  type = string
}

variable "vpc_name" {
  description = "name of vpc used by dev cluster"
  type        = string
}

variable "dev_cidr" {
	description = "Default cidr for VPC cluster"
	type = string
	default = "10.0.0.0/16"
}

variable "nodegroupname" {
	description = "Name of the nodegroup"
	type = string
    default = ""
}


variable "eksclustername" {
  description = "Name of the cluster"
  type = string
}

variable "nodegroupname" {
	description = "Name of the nodegroup"
	type = string
    default = ""
}

variable "instancetype" {
	description = "Default Instance Type"
	type = string
	default = "t4g.small"
}

variable "desired_node_count" {
	description = "number of nodes requested by user"
	type = number
	default = 3
}

variable "max_node_count" {
	description = "max nodes allowed"
	type = number
	default = 6
}

variable "min_node_count" {
	description = "minimum nodes for any deployment"
	type = number
	default = 2
}

variable "node_group_mgr_arn" {
  description = "Role with node management permissions"
  type = string
}

variable "private_subnet_Ids" {
	description = "list of subnet Ids available to the cluster"
	type = list
}


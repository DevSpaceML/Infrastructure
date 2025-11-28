variable "eksclustername" {
  description = "name of the cluster"
  type = string
}

variable "nodegroupname" {
  description = "name of nodegroup"
  type = string
  default = null
}

variable "desired_node_count" {
  description = "User preferred node count"
  type = number
}

variable "min_node_count" {
  description = "minimum number of nodes"
  type = number
}

variable "max_node_count" {
  description = "maximum allowed nodes"
  type = number
}

variable "instancetype" {
  description = "Instance type for the nodegroup"
  type = string
}


locals {
  nodegroup_name = var.nodegroupname != null ? var.nodegroupname : "${var.eksclustername}-nodegroup"
}

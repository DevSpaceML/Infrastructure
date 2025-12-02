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
  default = 4
}

variable "min_node_count" {
  description = "minimum number of nodes"
  type = number
  default = 2
}

variable "max_node_count" {
  description = "maximum allowed nodes"
  type = number
  default = 6
}

variable "instancetype" {
  description = "Instance type for the nodegroup"
  type = string
  default = "t4g.medium"
}

variable "k8s_version" {
  description = "Kubernetes version for the nodegroup"
  type = string
  default = "1.29"
}

locals {
  nodegroup_name = var.nodegroupname != null ? var.nodegroupname : "${var.eksclustername}-nodegroup"
}

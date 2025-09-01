variable "clustername" {
  description = "name of the dev cluster"
  type = string
}

variable "k8s_version" {
	description = "Version to be used with the cluster"
	type = string
}

variable "region" {
	description = "aws region"
	type = string
}

variable "instancetype" {
	description = "Default Instance Type"
	type = string
}

variable "vpcname" {
  description = "name of vpc used by dev cluster"
  type        = string
}

variable "dev_cidr" {
	description = "Default cidr block for VPC cluster"
	type = string
}

variable "nodegroupname" {
	description = "Name of the nodegroup"
	type = string
  default = ""
}

variable "desired_node_count" {
	description = "number of nodes requested by user"
	type = number
}

variable "max_node_count" {
	description = "max nodes allowed"
	type = number
}

variable "min_node_count" {
	description = "minimum nodes for any deployment"
	type = number
}

variable "kubeadmin-arn" {
  description = "ARN of the Kubernetes admin user/role"
  type        = string
}

variable "devops_user" {
  description = "DevOps user account running terraform"
  type        = string
}

variable "private_subnet_Ids" {
  description = "list of private subnet ids"
  type        = list(string)
  default = []
}

variable "access_entries" {
  description = "Map of access entries to create"
  type        = map(object({
	principal_arn = string
	kubernetes_groups = optional(list(string), [])
	type              = optional(string, "STANDARD")
	user_name         = optional(string)
	tags = optional(map(string), {})
  }))
}

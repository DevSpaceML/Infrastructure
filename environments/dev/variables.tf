variable "k8s_version" {
  description = "Version to be used with the cluster"
  type        = string
}

variable "instancetype" {
  description = "Default Instance Type"
  type        = string
}

variable "nodegroupname" {
  description = "Name of the nodegroup"
  type        = string
  default     = ""
}

variable "desired_node_count" {
  description = "number of nodes requested by user"
  type        = number
}

variable "max_node_count" {
  description = "max nodes allowed"
  type        = number
}

variable "min_node_count" {
  description = "minimum nodes for any deployment"
  type        = number
}

variable "private_subnet_Ids" {
  description = "list of private subnet ids"
  type        = list(string)
  default     = []
}

variable "access_entries" {
  description = "Access entries for EKS cluster"
  type = map(object({
    principal_arn      = string
    kubernetes_groups  = list(string)
    type              = string
    user_name         = optional(string)
  }))
  default = {}
}

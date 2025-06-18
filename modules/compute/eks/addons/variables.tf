variable "clustername" {
  description = "Name of the EKs Cluster"
  type = string
}

variable "rolearn" {
  description = "ARN of role with permission to access the nodes"
  type        = string 
}
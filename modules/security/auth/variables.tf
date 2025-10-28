variable "eksclustername" {
  description = "name of the eks cluster"
  type = string
}

variable "hosturl" {
  description = "host identifier"
  type = string
}

variable "noderolearn" {
  description = "eks node role"
  type        = string  
}

variable "clusteradminrole" {
  description = "role for cluster administration"
  type        = string
}
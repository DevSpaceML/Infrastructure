variable "private_cidr_block" {
	description = "private cidr block"
	type        =  list(string)
}

variable "public_cidr_block" {
	description = "public cidr block"
	type        =  list(string)
}

variable "eks_subnets" {
	description = "list of subnet Ids available to the cluster"
	type = list
}

variable "securitygroupId" {
	description = "id of eks security group"
	type = string
}

variable "cluster_vpc_id" {
	description = "id of the cluster vpc"
	type = string
}

variable "appdomain" {
	description = "name of project"
	type = string
}

variable "zoneid" {
  description = "hosted zone of app"
  type = string
}

variable "clustername" {
 	description = "name of cluster"
	type = string  
}


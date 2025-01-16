variable "security-groups" {
	description = "security groups of cluster vpc"
	type = string
}

variable "subnetIDs" {
	description = "list of subnet Ids available to the cluster"
	type = list
}

variable "securitygroupId" {
	description = "id of eks security group"
	type = string
}
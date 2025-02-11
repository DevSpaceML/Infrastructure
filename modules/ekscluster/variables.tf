#eks variables

variable "k8s_version" {
	description = "Version to be used with the cluster"
	type = string
	default = "1.29"
}

variable "environment" {
	description = "Environment cluster will be deployed in"
	type = string
	default = "development"
}

variable "project" {
	description = "Project running on cluster"
	type = string
	default = "development project"
}

variable "clustername" {
	description = "Name of cluster to be provisioned"
	type = string
	default = "analytics"
}

variable "vpcId" {
	description = "ID of the VPC containing the cluster"
	type = string	
}

variable "subnetIDs" {
	description = "list of subnet Ids available to the cluster"
	type = list
}

variable "public_cidr" {
	description = "Public facing CIDR block"
	type = list
}

variable "region" {
	description = "region to be deployed"
	type = string
	default = "us-east-1"
}

variable "rolearn" {
	description = "Role with eks permissions"
	type = string
	default = "arn:aws:iam::998787123729:role/socialweb"
}

variable "noderolearn" {
	description = "Role with NodeGroupPermissions"
	type = string
	default = "arn:aws:iam::998787123729:role/aws-service-role/eks-nodegroup.amazonaws.com/AWSServiceRoleForAmazonEKSNodegroup"
}

variable "nodegroupname" {
	description = "Name of the nodegroup"
	type = string
	default = "analytics_nodes"
}

variable "instancetype" {
	description = "Default Instance Type"
	type = string
	default = "t4g.medium"
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
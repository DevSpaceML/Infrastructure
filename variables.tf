#
variable "defaultregion" {
	description = "default aws region"
	type = string
	default = "us-east-1"
}

variable "nameofcluster"{
	description = "cluster name"
	type        = string
}
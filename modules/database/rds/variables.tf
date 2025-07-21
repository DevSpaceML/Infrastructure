variable "db_subnet_group_name"{
	description = "the name of the db subnet group"
	type = string
	default = ""
}

variable "iamaccountid"{
	description = "id to pass to arn"
	type = string
	default = ""
}

variable "private_subnet_Ids" {
  description = "list of private subnet ids"
  type        = list()
}
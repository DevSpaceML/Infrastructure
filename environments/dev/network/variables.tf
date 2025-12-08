
variable "dev_cidr" {
  description = "Default cidr block for VPC cluster"
  type        = string
}

variable "region" {
  description = "aws region"
  type        = string
}

variable "vpcname" {
  description = "name of vpc used by dev cluster"
  type        = string
}

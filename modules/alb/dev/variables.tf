variable "cert_arn" {
  description = "Cert arn from cert outputs"
  type = string
}

variable "public_dev_subnet_list" {
  description = "Public subnet for dev alb"
  type = list(string)
  default = []
}

variable "vpc_id" {
  description = "VPC ID for dev alb"
  type = string
}

variable "alb_sg_id" {
  description = "ALB security group ID"
  type = string
}
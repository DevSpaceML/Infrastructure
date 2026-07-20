variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "private_ecs_subnet_ids" {
  type = list(string)
  default = []
}
  
variable "ecs_security_group_id"  {
  type = string
}

variable "target_group_arn" {
  type = string
}

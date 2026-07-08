variable "aws_region" {
  type = string
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

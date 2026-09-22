variable "projectname" {
  description = "EKS project name"
  type = string
  default = ""
}

variable "vpc_id" {
  description = "vpc project will deploy to"
  type = string
}

variable "alb_securitygroup_id" {
  description = "ID of the security group for the ALB"
  type = string

}
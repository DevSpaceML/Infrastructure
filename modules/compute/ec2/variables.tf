variable "nginx_ami_id" {
  description = "ami for nginx server"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for nginx server"
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}
variable "nginx_ami_id" {
  description = "ami for nginx server"
  type        = string
  default     = "ami-0c94855ba95c71c99" # Amazon Linux 2 AMI (HVM), SSD Volume Type
}

variable "instance_type" {
  description = "EC2 instance type for nginx server"
  type        = string
  default     = "t4g.micro"
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}

variable "project_name" {
  description = "Project name for tagging resources"
  type        = string
}
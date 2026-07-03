variable "alb_dns_name" {
  description = "DNS name of the ALB"
  type = string
  default = ""
}

variable "appdomain" {
  description = "Domain name for the application"
  type = string
  default = "salientapps.com"
}

variable "appdomain" {
  description = "Domain name for the application"
  type = string
  default = "salientapps.com"
}

/*

variable "cf_api_token" {
  description = "Cloudflare API token for authentication"
  type = string
  default = null
}
  
variable "alb_dns_name" {
  description = "DNS name of the ALB"
  type = string
  default = ""
}


variable "cert_validation_options" {
  description = "Certificate validation options"
  type = list(object({
    domain_name = string
    resource_record_name = string
    resource_record_type = string
    resource_record_value = string
  }))
}

*/
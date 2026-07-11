variable "cert_validation_options" {
  description = "certificate validation options"
  type = list(object({
    domain_name = string
    resource_record_name = string
    resource_record_type = string
    resource_record_value = string
  }))
}

variable "domain_names" {
  description = "domain names for the cert"
  type = list(string)
}

variable "cert_arn"{
    description = "arn of the cert to validate"
    type = string
}
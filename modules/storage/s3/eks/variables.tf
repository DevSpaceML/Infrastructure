variable "projectname" {
  description = "name of project"
  type = string
}

variable "environment" {
  description = "deployment environment"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable versioning on Buckets"
  type        = "bool"
  default     = true  
}

variable "lifecycle_enabled" {
  description = "Enable lifecycle management"
  type        = bool
  default     = true
}

variable "backup_retention" {
  description = "Number of days to retain backups"
  type        = number
  default     = 365
}

# random suffix id

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

locals {
  bucket_suffix = random_id.bucket_suffix.hex
  common_tags = {
    Environment = var.environment
    Project     = var.projectname
    ManagedBy   = "terraform"
    Module      = "storage/s3"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  }
}

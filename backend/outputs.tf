output "s3_bucket_name" {
  description = "Name of s3 bucket for terraform state"
  value = aws_s3_bucket.tfStateFiles.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value = aws_s3_bucket.tfStateFiles.arn
}

output "s3_bucket_region" {
  description = "Region bucket resides in"
  value = aws_s3_bucket.tfStateFiles.region
}


resource "aws_s3_bucket" "app_artifacts" {
    bucket = "dev-app-artifacts"

    tags = {
    Name        = "dev-artifacts"
    Environment = "Dev"
  }
}
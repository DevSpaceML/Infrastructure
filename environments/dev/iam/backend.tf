terraform {
  backend "s3" {
    bucket = "dev-terraform-state-586098609239"
    key = "dev/iam/terraform.tfstate"
    region = "us-east-1"
  }
}
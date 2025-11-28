terraform {
  backend "s3" {
    bucket         = "dev-terraform-state-586098609239"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
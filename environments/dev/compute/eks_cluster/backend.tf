terraform {
  backend "s3" {
    bucket = "dev-terraform-state-586098609239"
    key = "dev/compute/eks_cluster/terraform.tfstate"
    region = "us-east-1"
  }
}
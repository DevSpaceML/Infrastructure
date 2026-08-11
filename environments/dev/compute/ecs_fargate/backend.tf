terraform {
  backend "s3" {
    bucket = "dev-tf-state-488347380548"
    key = "dev/compute/ecs_fargate/terraform.tfstate"
    region = "us-east-1"
  }
}
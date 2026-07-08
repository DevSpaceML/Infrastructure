resource "aws_s3_bucket" "terraform_tf_state" {
    bucket = "dev-tf-state-488347380548"
    tags = {
    Name        = "dev-terraform-tf-state"
    Environment = "Dev"
  }
}
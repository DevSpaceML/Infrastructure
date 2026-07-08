data "terraform_remote_state" "iam" {
    backend = "s3"
    config = {
        bucket = "dev-tf-state-488347380548"
        key    = "dev/iam/terraform.tfstate"
        region = "us-east-1"
    }
}
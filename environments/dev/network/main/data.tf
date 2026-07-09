data "terraform_remote_state" "iam" {
    backend = "s3"
    config = {
        bucket = "dev-tf-state-488347380548"
        key    = "dev/iam/terraform.tfstate"
        region = "us-east-1"
    }
}

data "terraform_remote_state" "dev_network" {
    backend = "s3"
    config = {
        bucket = "dev-tf-state-488347380548"
        key    = "dev/network/terraform.tfstate"
        region = "us-east-1"
    }
}
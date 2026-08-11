data "terraform_remote_state" "dev_network" {
    backend = "s3"
    config = {
        bucket = "dev-tf-state-488347380548"
        key    = "dev/network/main/terraform.tfstate"
        region = "us-east-1"
    }
}


data "terraform_remote_state" "dev_alb" {
    backend = "s3"
    config = {
        bucket = "dev-tf-state-488347380548"
        key    = "dev/alb/main/terraform.tfstate"
        region = "us-east-1"
    }
}

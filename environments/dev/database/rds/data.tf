data terraform_remote_state "dev_vpc" {
    backend = "s3"
    config = {
        bucket = "dev-terraform-state-586098609239" 
        key    = "dev/network/terraform.tfstate"
        region = "us-east-1"
    }
}
    
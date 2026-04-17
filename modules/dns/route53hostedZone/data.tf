
data "terraform_remote_state" "dns" {
    backend = "s3"
    config = {
        bucket = "dev-terraform-state-586098609239"
        key    = "dev/dns/terraform.tfstate"
        region = "us-east-1"
    } 
}
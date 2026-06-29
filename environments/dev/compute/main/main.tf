data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-*-arm64"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "nginx_instance" {
  source = "../../modules/compute/ec2/dev"
  environment = var.environment
  instance_type = var.instance_type
  ami_id = data.aws_ami.al2023.id
  key_name = "dev-key-pair"
}

module "artifacts_bucket" {
  source = "../../modules/storage/s3/dev"
}
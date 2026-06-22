
resource "aws_instance" "nginx-instance" {
  ami           = var.nginx_ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  tags = {
    Name = "dev-nginx-instance"
  }
}
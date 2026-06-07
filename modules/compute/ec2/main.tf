resource "aws_instance" "nginx" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  tags = {
    Name = "nginx-instance"
  }
}
resource "aws_lb" "k8_shared" {
  name               = "k8_shared_alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_securitygroup_id]
  subnets            = var.public_subnet_ids

  tags = {
    Name        = "k8-shared-alb"
    Environment = "Dev"
  }
}



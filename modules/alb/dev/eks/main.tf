resource "aws_lb" "k8_shared" {
  name               = "k8_shared_alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = var.alb_securitygroup_id
}



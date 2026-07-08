
/* ALB, target-groups, listeners */

resource "aws_lb" "dev_alb" {
  name               = "dev-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for s in var.public_dev_subnet_list : s.id]

  tags = {
    Name        = "dev-alb"
    Environment = "Dev"
  }
}

resource "aws_alb_target_group" "ecs-slfsvc-tg" {
  name     = "ecs-slfsvc-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name        = "ecs-slfsvc-tg"
    Environment = "Dev"
  }
  
}

resource "aws_lb_listener" "slfsvc-listener" {
  load_balancer_arn = aws_lb.dev_alb.arn  
  port              = 443
  protocol          = "HTTP"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn    = var.cert_arn

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: Not Found"
      status_code  = "404"
    }
  }
}
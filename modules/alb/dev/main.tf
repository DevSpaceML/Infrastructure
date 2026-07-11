
/* ALB, target-groups, listeners */

resource "aws_lb" "dev_alb" {
  name               = "dev-shared-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_dev_subnet_list

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

resource "aws_lb_listener" "http-redirect" {
  load_balancer_arn = aws_lb.dev_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "slfsvc-listener" {
  load_balancer_arn = aws_lb.dev_alb.arn  
  port              = 443
  protocol          = "HTTPS"
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

resource "aws_lb_listener_rule" "slfsrv-listener-rule" {
  listener_arn = aws_lb_listener.slfsvc-listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs-slfsvc-tg.arn
  }

  condition {
    host_header {
      values = ["var.domain_name"]
    }
  }
}
resource "aws_lb_target_group" "project" {
  name        = "tg-${var.projectname}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path = "/healthz"
  }
}

resource "aws_lb_listener_rule" "project" {
  listener_arn = var.alb_arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.project.arn
  }

  condition {
    host_header {
      values = ["${var.projectname}.salientapps.com"]
    }
  }
}
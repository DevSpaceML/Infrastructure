data "aws_lb" "k8_shared" {
  arn  = var.alb_arn
  name = var.alb_name
}

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
  listener_arn = aws_lb.k8_shared.arn
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

resource "aws_iam_policy" "alb_controller" {
  name = "${var.clustername}-alb-controller"
  policy = file("${path.module/alb-controller.json}")
}

resource "cloudflare_record" "app" {
  zone_id = var.cloudflare_zone_id
  name    =  "app"
  type    = "CNAME"
  content =  data.aws_lb.k8_shared.dns_name
  proxied = true
}
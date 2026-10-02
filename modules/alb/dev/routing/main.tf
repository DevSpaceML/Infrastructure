terraform {
  required_providers {
    aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
      }
      cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.26.0"
    }
  }
}

data "aws_lb" "k8_shared" {
  arn  = var.alb_arn
  name = var.alb_name
}

data "cloudflare_zone" "this" {
  filter = {
    name = var.appdomain
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = data.aws_lb.k8_shared.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
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
  listener_arn = aws_lb_listener.http.arn
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

resource "cloudflare_dns_record" "app" {
  zone_id =  data.cloudflare_zone.this.zone_id
  name    =  var.projectname
  type    = "CNAME"
  content =  data.aws_lb.k8_shared.dns_name
  proxied = true
  ttl     = 1
}
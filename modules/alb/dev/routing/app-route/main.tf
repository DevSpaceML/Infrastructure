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

data "aws_lb_listener" "https" {
  load_balancer_arn = var.alb_arn
  port              = 443
}

locals {
  env_domain = var.environment == "prod" ? var.appdomain : "${var.environment}.${var.appdomain}"
  label      = var.projinstance_id ? "${var.projinstance_id}-${var.environment}-${var.projectname}" : var.appdomain
  fqdn       = "${var.projectname}.${local.env_domain}"
  tg_name    = "tg-${substr(md5(local.fqdn), 0, 12)}"
}

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = data.aws_lb.k8_shared.arn
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

resource "aws_lb_listener" "https" {
  load_balancer_arn = data.aws_lb.k8_shared.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn        # per-env ACM cert

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_target_group" "traefik" {
  name        = local.tg_name
  port        = var.traefik_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  deregistration_delay = 30

  health_check {
    port                = "traffic-port"
    protocol            = "HTTP"
    path                = "/healthz"
    matcher             = "200"
    interval            = 15
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = local.label
    Environment = var.environment
    hostname     = local.fqdn
  }

}

resource "aws_lb_listener_rule" "project" {
  listener_arn = aws_lb_listener.https.arn 

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.project.arn
  }

  condition {
    host_header {
      values = [local.fqdn]
    }
  }
}

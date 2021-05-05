# NLB
resource "aws_lb" "gokabot-nlb" {
  name = "gokabot-nlb"

  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false
  internal                         = false
  ip_address_type                  = "ipv4"

  subnets = [
    var.subnets.a.id,
    var.subnets.c.id
  ]

  access_logs {
    enabled = true
    bucket  = var.s3_bucket.id
  }

  tags = {
    Name = "gokabot-nlb"
    cost = var.cost_tag
  }
}

# Target group - 1
resource "aws_lb_target_group" "gokabot-tg-01" {
  name = "gokabot-tg-01"

  vpc_id      = var.vpc.id
  port        = var.target.port
  protocol    = var.target.protocol
  target_type = var.target.target_type

  health_check {
    enabled             = var.target.health_check.enabled
    interval            = var.target.health_check.interval
    healthy_threshold   = var.target.health_check.healthy_threshold
    unhealthy_threshold = var.target.health_check.unhealthy_threshold
  }

  stickiness {
    enabled = var.target.stickiness.enabled
    type    = var.target.stickiness.type
  }

  tags = {
    Name = "gokabot-tg-01"
    cost = var.cost_tag
  }
}

# Target group - 2
resource "aws_lb_target_group" "gokabot-tg-02" {
  name = "gokabot-tg-02"

  vpc_id      = var.vpc.id
  port        = var.target.port
  protocol    = var.target.protocol
  target_type = var.target.target_type

  health_check {
    enabled             = var.target.health_check.enabled
    interval            = var.target.health_check.interval
    healthy_threshold   = var.target.health_check.healthy_threshold
    unhealthy_threshold = var.target.health_check.unhealthy_threshold
  }

  stickiness {
    enabled = var.target.stickiness.enabled
    type    = var.target.stickiness.type
  }

  tags = {
    Name = "gokabot-tg-02"
    cost = var.cost_tag
  }
}

# Listener - HTTP
resource "aws_lb_listener" "gokabot-nlb-listener-80" {
  load_balancer_arn = aws_lb.gokabot-nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gokabot-tg-01.arn
  }
}

# Get cert
data "aws_acm_certificate" "domain" {
  domain   = var.domain
  statuses = ["ISSUED"]
}

# Listener - HTTPS
resource "aws_lb_listener" "gokabot-nlb-listener-443" {
  load_balancer_arn = aws_lb.gokabot-nlb.arn

  port            = 443
  protocol        = "TLS"
  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = data.aws_acm_certificate.domain.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gokabot-tg-02.arn
  }
}

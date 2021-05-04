data "aws_route53_zone" "gokabot-com" {
  name = "gokabot.com"
}

resource "aws_route53_record" "dev-gokabot-com-a" {
  zone_id = data.aws_route53_zone.gokabot-com.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = var.lb.dns_name
    zone_id                = var.lb.zone_id
    evaluate_target_health = false
  }
}

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

data "aws_route53_zone" "gokabot" {
  name = "gokabot.com"
}

resource "aws_lightsail_certificate" "api" {
  name        = "gokabot-api-cert"
  domain_name = "api.gokabot.com"
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_lightsail_certificate.api.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.gokabot.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]
  ttl     = 60
}

resource "aws_lightsail_container_service" "gokabot_api" {
  name  = "gokabot-api"
  power = "nano"
  scale = 1

  public_domain_names {
    certificate {
      certificate_name = aws_lightsail_certificate.api.name
      domain_names     = ["api.gokabot.com"]
    }
  }

  tags = {
    Project = "gokabot"
  }
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.gokabot.zone_id
  name    = "api.gokabot.com"
  type    = "CNAME"
  ttl     = 300
  records = [trimsuffix(trimprefix(aws_lightsail_container_service.gokabot_api.url, "https://"), "/")]
}

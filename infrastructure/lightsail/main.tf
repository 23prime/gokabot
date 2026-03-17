terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

resource "aws_lightsail_container_service" "gokabot_api" {
  name  = "gokabot-api"
  power = "nano"
  scale = 1

  tags = {
    Project = "gokabot"
  }
}

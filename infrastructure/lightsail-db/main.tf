terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

resource "random_password" "master" {
  length           = 32
  special          = true
  override_special = "-._~" # URL-safe unreserved characters only
}

resource "aws_lightsail_database" "gokabot" {
  relational_database_name = "gokabot-db-prod"
  availability_zone        = "ap-northeast-1a"
  master_database_name     = "gokabot_db"
  master_username          = "gokabot"
  master_password          = random_password.master.result
  blueprint_id             = "postgres_18"
  bundle_id                = "micro_2_0"
  publicly_accessible      = false
  skip_final_snapshot      = true

  tags = {
    Project = "gokabot"
  }
}

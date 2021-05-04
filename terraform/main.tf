terraform {
  required_version = "0.14.8"

  backend "s3" {
    bucket = "tfstate-gokabot"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }

  required_providers {
    aws = "3.32.0"
  }
}

provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = var.aws_region
}

module "vpc" {
  source   = "./modules/vpc"
  cost_tag = "gokabot"
}

module "subnet" {
  source   = "./modules/subnet"
  cost_tag = "gokabot"
  vpc      = module.vpc.gokabot-vpc
}

module "security_group" {
  source   = "./modules/security_group"
  cost_tag = "gokabot"
  vpc      = module.vpc.gokabot-vpc
}

module "iam" {
  source   = "./modules/iam"
  cost_tag = var.cost_tag
}

module "ssm" {
  source   = "./modules/ssm"
  cost_tag = var.cost_tag

  # SSM Parameters
  database_url = var.database_url

  line_channel_secret = var.line_channel_secret
  line_channel_token  = var.line_channel_token
  my_user_id          = var.my_user_id
  gokabou_user_id     = var.gokabou_user_id
  nga_group_id        = var.nga_group_id
  kmt_group_id        = var.kmt_group_id

  discord_bot_token             = var.discord_bot_token
  discord_target_channel_id     = var.discord_target_channel_id
  discord_target_channel_id_dev = var.discord_target_channel_id_dev

  open_weather_api_key = var.open_weather_api_key
}

module "lb" {
  source   = "./modules/lb"
  cost_tag = "gokabot"
  vpc      = module.vpc.gokabot-vpc
  subnets = {
    a = module.subnet.gokabot-public-subnet-a
    c = module.subnet.gokabot-public-subnet-c
  }
}

module "route53" {
  source = "./modules/route53"
  lb     = module.lb.gokabot-nlb
}

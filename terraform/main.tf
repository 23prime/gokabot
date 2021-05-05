terraform {
  required_version = "0.14.8"

  backend "s3" {
    bucket = "tfstate-gokabot"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }

  required_providers {
    aws = "3.38.0"
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
  source      = "./modules/subnet"
  cost_tag    = "gokabot"
  vpc         = module.vpc.gokabot-vpc
  route_table = module.vpc.gokabot-route-table
}

module "sg" {
  source   = "./modules/sg"
  cost_tag = "gokabot"
  vpc      = module.vpc.gokabot-vpc
}

module "vpc_endpoint" {
  source      = "./modules/vpc_endpoint"
  cost_tag    = "gokabot"
  region      = var.aws_region
  vpc         = module.vpc.gokabot-vpc
  route_table = module.vpc.gokabot-route-table
  subnets = {
    a = module.subnet.gokabot-private-subnet-a
    c = module.subnet.gokabot-private-subnet-c
  }
  sg = module.sg.gokabot-vpc-endpoint-sg
}

module "iam" {
  source          = "./modules/iam"
  cost_tag        = var.cost_tag
  dockerhub_login = module.secret.dockerhub-login
}

module "ssm" {
  source   = "./modules/ssm"
  cost_tag = var.cost_tag

  # SSM Parameters
  database_url                  = var.database_url
  line_channel_secret           = var.line_channel_secret
  line_channel_token            = var.line_channel_token
  my_user_id                    = var.my_user_id
  gokabou_user_id               = var.gokabou_user_id
  nga_group_id                  = var.nga_group_id
  kmt_group_id                  = var.kmt_group_id
  discord_bot_token             = var.discord_bot_token
  discord_target_channel_id     = var.discord_target_channel_id
  discord_target_channel_id_dev = var.discord_target_channel_id_dev
  open_weather_api_key          = var.open_weather_api_key
}

module "secret" {
  source          = "./modules/secret"
  cost_tag        = var.cost_tag
  docker_hub_id   = var.docker_hub_id
  docker_hub_pass = var.docker_hub_pass
}

module "s3" {
  source   = "./modules/s3"
  cost_tag = "gokabot"
}

module "lb" {
  source   = "./modules/lb"
  cost_tag = "gokabot"
  vpc      = module.vpc.gokabot-vpc
  subnets = {
    a = module.subnet.gokabot-public-subnet-a
    c = module.subnet.gokabot-public-subnet-c
  }
  s3_bucket = module.s3.gokabot-nlb-logs
  domain    = var.domain
}

module "route53" {
  source = "./modules/route53"
  lb     = module.lb.gokabot-nlb
  domain = var.domain
}

module "cw_logs" {
  source   = "./modules/cw_logs"
  cost_tag = var.cost_tag
}

module "ecr" {
  source   = "./modules/ecr"
  cost_tag = var.cost_tag
}

module "ecs" {
  source         = "./modules/ecs"
  cost_tag       = var.cost_tag
  container_port = var.container_port
  region         = var.aws_region
  vpc            = module.vpc.gokabot-vpc
  subnets = {
    a = module.subnet.gokabot-private-subnet-a
    c = module.subnet.gokabot-private-subnet-c
  }
  sg                  = module.sg.gokabot-service-sg
  tg                  = module.lb.gokabot-tg-01
  ssm_params          = module.ssm.gokabot-ssm-params
  task_execution_role = module.iam.GokabotTaskExecutionRole
  ecr_repo            = module.ecr.gokabot-core-api-repo
  log_group           = module.cw_logs.gokabot-core-api-log-group
}

module "codebuild" {
  source         = "./modules/codebuild"
  account_id     = var.aws_account_id
  region         = var.aws_region
  cost_tag       = var.cost_tag
  codebuild_role = module.iam.GokabotCodeBuildServiceRole
  ecr_repo       = module.ecr.gokabot-core-api-repo
}

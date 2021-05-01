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
  vpc_id   = module.vpc.gokabot-vpc.id
}

module "security_group" {
  source   = "./modules/security_group"
  cost_tag = "gokabot"
  vpc_id   = module.vpc.gokabot-vpc.id
  # vpc_cidr_block = module.vpc.gokabot-vpc.cidr_block
}

locals {
  aws_region = "ap-northeast-1"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
}
EOF
}

remote_state {
  backend = "s3"
  config = {
    bucket  = "gokabot-tfstate"
    key     = "${path_relative_to_include()}/terraform.tfstate"
    region  = local.aws_region
    encrypt = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

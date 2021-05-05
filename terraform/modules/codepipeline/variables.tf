variable "region" {
  type = string
}

variable "cost_tag" {
  type = string
}

variable "codepipeline_role" {
  type = any
}

variable "s3_bucket" {
  type = any
}

variable "codecommit_repository_name" {
  type = string
}

variable "build_project" {
  type = any
}

variable "deploy_app" {
  type = any
}

variable "deploy_group" {
  type = any
}

variable "account_id" {
  type = string
}

variable "region" {
  type = string
}

variable "cost_tag" {
  type = string
}

variable "codebuild_role" {
  type = any
}

variable "ecr_repo" {
  type = any
}

variable "codecommit_repository_name" {
  type = string
}

variable "aws_access_key_id" {
  type = string
}

variable "aws_secret_access_key" {
  type = string
}

variable "aws_region" {
  type = string

  default = "ap-northeast-1"
}

variable "cost_tag" {
  type = string

  default = "gokabot"
}

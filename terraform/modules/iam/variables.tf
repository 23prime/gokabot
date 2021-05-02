variable "cost_tag" {
  type = string
}

variable "ssm_parameter_gokabot_all" {
  type = string

  default = "arn:aws:ssm:ap-northeast-1:678084882233:parameter/gokabot*"
}

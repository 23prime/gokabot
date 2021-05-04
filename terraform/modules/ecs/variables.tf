variable "cost_tag" {
  type = string
}

variable "region" {
  type = string
}

variable "container_port" {
  type = number
}

variable "vpc" {
  type = any
}

variable "subnets" {
  type = object({
    a = any,
    c = any
  })
}

variable "sg" {
  type = any
}

variable "tg" {
  type = any
}

variable "ssm_params" {
  type = any
}

variable "task_execution_role" {
  type = any
}

variable "ecr_repo" {
  type = any
}

variable "log_group" {
  type = any
}

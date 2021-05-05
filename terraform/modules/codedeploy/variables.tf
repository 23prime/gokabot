variable "cost_tag" {
  type = string
}

variable "ecs_cluster" {
  type = any
}

variable "ecs_service" {
  type = any
}

variable "codedeploy_role" {
  type = any
}

variable "nlb_listener" {
  type = any
}

variable "tgs" {
  type = list(any)
}

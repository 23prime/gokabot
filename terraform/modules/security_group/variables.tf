variable "cost_tag" {
  type = string
}

variable "vpc" {
  type = any
}

variable "container-http-port" {
  type = number

  default = 8080
}

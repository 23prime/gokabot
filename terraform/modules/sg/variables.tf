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

variable "ports" {
  type = object({
    min = number
    max = number
  })

  default = {
    min = 0
    max = 65535
  }
}

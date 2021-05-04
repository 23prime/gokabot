variable "cost_tag" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc" {
  type = any
}

variable "route_table" {
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

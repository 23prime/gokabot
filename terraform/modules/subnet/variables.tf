variable "cost_tag" {
  type = string
}

variable "vpc" {
  type = any
}

variable "cidr_block" {
  type = object({
    public-a  = string
    public-c  = string
    private-a = string
    private-c = string
  })

  default = {
    public-a  = "10.10.10.0/24"
    public-c  = "10.10.11.0/24"
    private-a = "10.10.20.0/24"
    private-c = "10.10.21.0/24"
  }
}

variable "az" {
  type = object({
    a = string
    c = string
  })

  default = {
    a = "ap-northeast-1a"
    c = "ap-northeast-1c"
  }
}

variable "route_table" {
  type = any
}

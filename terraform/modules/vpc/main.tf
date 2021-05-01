resource "aws_vpc" "gokabot-vpc" {
  cidr_block = var.cidr_block

  tags = {
    Name = "gokabot-vpc"
    cost = var.cost_tag
  }
}

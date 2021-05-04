resource "aws_vpc" "gokabot-vpc" {
  cidr_block = var.cidr_block

  tags = {
    Name = "gokabot-vpc"
    cost = var.cost_tag
  }
}

resource "aws_internet_gateway" "gokabot-igw" {
  vpc_id = aws_vpc.gokabot-vpc.id

  tags = {
    Name = "gokabot-igw"
    cost = var.cost_tag
  }
}

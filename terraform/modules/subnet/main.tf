resource "aws_subnet" "gokabot-public-subnet-a" {
  vpc_id            = var.vpc.id
  cidr_block        = var.cidr_block.public-a
  availability_zone = var.az.a

  tags = {
    Name = "gokabot-public-subnet-a"
    cost = var.cost_tag
  }
}

resource "aws_subnet" "gokabot-public-subnet-c" {
  vpc_id            = var.vpc.id
  cidr_block        = var.cidr_block.public-c
  availability_zone = var.az.c

  tags = {
    Name = "gokabot-public-subnet-c"
    cost = var.cost_tag
  }
}

resource "aws_subnet" "gokabot-private-subnet-a" {
  vpc_id            = var.vpc.id
  cidr_block        = var.cidr_block.private-a
  availability_zone = var.az.a

  tags = {
    Name = "gokabot-private-subnet-a"
    cost = var.cost_tag
  }
}

resource "aws_subnet" "gokabot-private-subnet-c" {
  vpc_id            = var.vpc.id
  cidr_block        = var.cidr_block.private-c
  availability_zone = var.az.c

  tags = {
    Name = "gokabot-private-subnet-c"
    cost = var.cost_tag
  }
}

# Public subnet - zone a
resource "aws_subnet" "gokabot-public-subnet-a" {
  vpc_id            = var.vpc.id
  cidr_block        = var.cidr_block.public-a
  availability_zone = var.az.a

  tags = {
    Name = "gokabot-public-subnet-a"
    cost = var.cost_tag
  }
}

# Public subnet - zone c
resource "aws_subnet" "gokabot-public-subnet-c" {
  vpc_id            = var.vpc.id
  cidr_block        = var.cidr_block.public-c
  availability_zone = var.az.c

  tags = {
    Name = "gokabot-public-subnet-c"
    cost = var.cost_tag
  }
}

# Private subnet - zone a
resource "aws_subnet" "gokabot-private-subnet-a" {
  vpc_id            = var.vpc.id
  cidr_block        = var.cidr_block.private-a
  availability_zone = var.az.a

  tags = {
    Name = "gokabot-private-subnet-a"
    cost = var.cost_tag
  }
}

resource "aws_route_table_association" "gokabot-route-table-association-a" {
  subnet_id      = aws_subnet.gokabot-private-subnet-a.id
  route_table_id = var.route_table.id
}

# Private subnet - zone c
resource "aws_subnet" "gokabot-private-subnet-c" {
  vpc_id            = var.vpc.id
  cidr_block        = var.cidr_block.private-c
  availability_zone = var.az.c

  tags = {
    Name = "gokabot-private-subnet-c"
    cost = var.cost_tag
  }
}

resource "aws_route_table_association" "gokabot-route-table-association-c" {
  subnet_id      = aws_subnet.gokabot-private-subnet-c.id
  route_table_id = var.route_table.id
}

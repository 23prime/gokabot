# VPC
resource "aws_vpc" "gokabot-vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "gokabot-vpc"
    cost = var.cost_tag
  }
}

# Internet gateway
resource "aws_internet_gateway" "gokabot-igw" {
  vpc_id = aws_vpc.gokabot-vpc.id

  tags = {
    Name = "gokabot-igw"
    cost = var.cost_tag
  }
}

# Internet access for public
resource "aws_route" "public-igw-route" {
  route_table_id         = aws_vpc.gokabot-vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gokabot-igw.id
}

# Private route table
resource "aws_route_table" "gokabot-route-table" {
  vpc_id = aws_vpc.gokabot-vpc.id

  tags = {
    Name = "gokabot-route-table"
    cost = var.cost_tag
  }
}

# Internet access for private
resource "aws_route" "private-igw-route" {
  route_table_id         = aws_route_table.gokabot-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gokabot-igw.id
}

# Peering to default VPC
data "aws_vpc" "default" {
  default = true
}

resource "aws_vpc_peering_connection" "gokabot-vpc-peering-rds" {
  vpc_id      = aws_vpc.gokabot-vpc.id
  peer_vpc_id = data.aws_vpc.default.id
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "gokabot-vpc-peering-rds"
    cost = var.cost_tag
  }
}

resource "aws_route" "vpc-peering-route" {
  route_table_id            = aws_route_table.gokabot-route-table.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.gokabot-vpc-peering-rds.id
}

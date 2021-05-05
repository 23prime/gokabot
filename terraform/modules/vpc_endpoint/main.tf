resource "aws_vpc_endpoint" "gokabot-s3" {
  vpc_id            = var.vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "gokabot-s3"
    cost = var.cost_tag
  }
}

resource "aws_vpc_endpoint_route_table_association" "gokabot-vpc-endpoint-route-table-association" {
  vpc_endpoint_id = aws_vpc_endpoint.gokabot-s3.id
  route_table_id  = var.route_table.id
}

resource "aws_vpc_endpoint" "gokabot-ecr-dkr" {
  vpc_id              = var.vpc.id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.subnets.a.id, var.subnets.c.id]
  security_group_ids  = [var.sg.id]
  private_dns_enabled = true

  tags = {
    Name = "gokabot-ecr-dkr"
    cost = var.cost_tag
  }
}

resource "aws_vpc_endpoint" "gokabot-ecr-api" {
  vpc_id              = var.vpc.id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.subnets.a.id, var.subnets.c.id]
  security_group_ids  = [var.sg.id]
  private_dns_enabled = true

  tags = {
    Name = "gokabot-ecr-api"
    cost = var.cost_tag
  }
}

resource "aws_vpc_endpoint" "gokabot-cwlogs" {
  vpc_id              = var.vpc.id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.subnets.a.id, var.subnets.c.id]
  security_group_ids  = [var.sg.id]
  private_dns_enabled = true

  tags = {
    Name = "gokabot-cwlogs"
    cost = var.cost_tag
  }
}

resource "aws_vpc_endpoint" "gokabot-ssm" {
  vpc_id              = var.vpc.id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.subnets.a.id, var.subnets.c.id]
  security_group_ids  = [var.sg.id]
  private_dns_enabled = true

  tags = {
    Name = "gokabot-ssm"
    cost = var.cost_tag
  }
}

resource "aws_vpc_endpoint" "gokabot-codedeploy" {
  vpc_id              = var.vpc.id
  service_name        = "com.amazonaws.${var.region}.codedeploy"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.subnets.a.id, var.subnets.c.id]
  security_group_ids  = [var.sg.id]
  private_dns_enabled = true

  tags = {
    Name = "gokabot-codedeploy"
    cost = var.cost_tag
  }
}

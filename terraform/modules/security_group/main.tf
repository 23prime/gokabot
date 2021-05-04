resource "aws_security_group" "gokabot-service-sg" {
  name        = "gokabot-service-sg"
  description = "For Gokabot ECS service"
  vpc_id      = var.vpc.id

  tags = {
    Name = "gokabot-service-sg"
    cost = var.cost_tag
  }
}

resource "aws_security_group_rule" "gokabot-service-egress" {
  security_group_id = aws_security_group.gokabot-service-sg.id
  type              = "egress"

  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
}

resource "aws_security_group_rule" "gokabot-service-container-http" {
  security_group_id = aws_security_group.gokabot-service-sg.id
  type              = "ingress"

  cidr_blocks = [var.vpc.cidr_block]
  from_port   = var.container-http-port
  to_port     = var.container-http-port
  protocol    = "tcp"
}

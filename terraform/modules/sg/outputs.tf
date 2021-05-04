output "gokabot-service-sg" {
  value = aws_security_group.gokabot-service-sg
}

output "gokabot-vpc-endpoint-sg" {
  value = aws_security_group.gokabot-vpc-endpoint-sg
}

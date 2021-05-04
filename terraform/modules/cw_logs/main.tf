resource "aws_cloudwatch_log_group" "gokabot-core-api-log-group" {
  name = "gokabot-core-api"

  retention_in_days = 400

  tags = {
    Name = "gokabot-core-api"
    cost = var.cost_tag
  }
}

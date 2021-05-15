resource "aws_cloudwatch_event_bus" "gokabot-event-bus" {
  name = "gokabot-event-bus"

  tags = {
    Name = "gokabot-event-bus"
    cost = var.cost_tag
  }
}

# Get source repository data
data "aws_codecommit_repository" "gokabot" {
  repository_name = var.codecommit_repository_name
}

resource "aws_cloudwatch_event_rule" "gokabot-codepipeline-event-rule" {
  name = "gokabot-codepipeline-event-rule"

  event_bus_name = aws_cloudwatch_event_bus.gokabot-event-bus.name
  event_pattern = jsonencode(
    {
      detail = {
        event = [
          "referenceCreated",
          "referenceUpdated",
        ]
        referenceName = [
          "master",
        ]
        referenceType = [
          "branch",
        ]
      }
      source = [
        "aws.codecommit",
      ]
      detail-type = [
        "CodeCommit Repository State Change",
      ]
      resources = [
        data.aws_codecommit_repository.gokabot.arn
      ]
    }
  )

  tags = {
    Name = "gokabot-codepipeline-event-rule"
    cost = var.cost_tag
  }
}

resource "aws_cloudwatch_event_target" "gokabot-codepipeline-event-target" {
  target_id = "gokabot-codepipeline-event-target"

  event_bus_name = aws_cloudwatch_event_bus.gokabot-event-bus.name
  rule           = aws_cloudwatch_event_rule.gokabot-codepipeline-event-rule.name
  role_arn       = var.event_target_role.arn

  arn = var.codepipeline.arn
}

output "gokabot-ecs-service-deploy" {
  value = aws_codedeploy_app.gokabot-ecs-service-deploy
}

output "gokabot-ecs-service-deploy-group" {
  value = aws_codedeploy_deployment_group.gokabot-ecs-service-deploy-group
}

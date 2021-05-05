output "gokabot-cluster" {
  value = aws_ecs_cluster.gokabot-cluster
}

output "gokabot-service" {
  value = aws_ecs_service.gokabot-service
}

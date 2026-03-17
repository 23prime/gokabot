output "url" {
  description = "Public URL of the Lightsail container service"
  value       = aws_lightsail_container_service.gokabot_api.url
}

output "endpoint" {
  description = "Endpoint of the Lightsail database"
  value       = aws_lightsail_database.gokabot.master_endpoint_address
}

output "port" {
  description = "Port of the Lightsail database"
  value       = aws_lightsail_database.gokabot.master_endpoint_port
}

output "master_username" {
  description = "Master username of the Lightsail database"
  value       = aws_lightsail_database.gokabot.master_username
}

output "master_password" {
  description = "Master password of the Lightsail database"
  value       = random_password.master.result
  sensitive   = true
}

output "database_url" {
  description = "DATABASE_URL for the Go API"
  value       = "postgres://${aws_lightsail_database.gokabot.master_username}:${random_password.master.result}@${aws_lightsail_database.gokabot.master_endpoint_address}:${aws_lightsail_database.gokabot.master_endpoint_port}/gokabot_db?sslmode=require"
  sensitive   = true
}

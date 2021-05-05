resource "aws_secretsmanager_secret" "dockerhub-login" {
  name = "dockerhub-login"

  tags = {
    Name = "dockerhub-login"
    cost = var.cost_tag
  }
}

resource "aws_secretsmanager_secret_version" "dockerhub-login" {
  secret_id = aws_secretsmanager_secret.dockerhub-login.id
  secret_string = jsonencode(
    {
      docker_hub_id   = var.docker_hub_id
      docker_hub_pass = var.docker_hub_pass
    }
  )
}

resource "aws_ecr_repository" "gokabot-core-api" {
  name = "gokabot-core-api"

  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    Name = "gokabot-core-api"
    cost = var.cost_tag
  }
}

# Since the following error occurs, so copy and paste the JSON file with the GUI.
# [Invalid parameter at 'PolicyText' failed to satisfy constraint: 'Invalid repository policy provided']
# resource "aws_ecr_registry_policy" "gokabot-registry-policy" {
#   policy = file("${path.module}/registry_policy.json")
# }

resource "aws_ecr_lifecycle_policy" "gokabot-lifecycle-policy" {
  repository = aws_ecr_repository.gokabot-core-api.name
  policy     = file("${path.module}/lifecycle_policy.json")
}

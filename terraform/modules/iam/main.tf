# Get KMS Key data
data "aws_kms_key" "ssm_key" {
  key_id = "alias/aws/ssm"
}

# For GokabotTaskExecutionRole
resource "aws_iam_policy" "GokabotSecretAccess" {
  name = "GokabotSecretAccess"
  path = "/service-role/"

  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Action = [
            "ssm:GetParameters",
            "kms:Decrypt",
          ]
          Effect = "Allow"
          Resource = [
            var.ssm_parameter_gokabot_all,
            data.aws_kms_key.ssm_key.arn
          ]
        }
      ]
    }
  )

  tags = {
    Name = "GokabotSecretAccess"
    cost = var.cost_tag
  }
}

resource "aws_iam_role" "GokabotTaskExecutionRole" {
  name = "GokabotTaskExecutionRole"
  path = "/service-role/"

  assume_role_policy = file("${path.module}/assume_role_policy_ecs_task.json")

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    aws_iam_policy.GokabotSecretAccess.arn
  ]

  tags = {
    Name = "GokabotTaskExecutionRole"
    cost = var.cost_tag
  }
}

# For GokabotCodeBuildServiceRole
resource "aws_iam_policy" "GokabotCodeBuildBasePolicy" {
  name = "GokabotCodeBuildBasePolicy"
  path = "/service-role/"

  policy = file("${path.module}/codebuild_base_policy.json")

  tags = {
    Name = "GokabotCodeBuildBasePolicy"
    cost = var.cost_tag
  }
}

resource "aws_iam_policy" "SecretsManagerGetDockerHubLogin" {
  name = "SecretsManagerGetDockerHubLogin"
  path = "/service-role/"

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action   = "secretsmanager:GetSecretValue"
          Effect   = "Allow"
          Resource = var.dockerhub_login.arn
        },
      ]
    }
  )

  tags = {
    Name = "SecretsManagerGetDockerHubLogin"
    cost = var.cost_tag
  }
}

resource "aws_iam_role" "GokabotCodeBuildServiceRole" {
  name = "GokabotCodeBuildServiceRole"
  path = "/service-role/"

  assume_role_policy = file("${path.module}/assume_role_policy_codebuild.json")

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
    aws_iam_policy.GokabotCodeBuildBasePolicy.arn,
    aws_iam_policy.SecretsManagerGetDockerHubLogin.arn
  ]

  tags = {
    Name = "GokabotCodeBuildServiceRole"
    cost = var.cost_tag
  }
}

# Get KMS Key data
data "aws_kms_key" "ssm_key" {
  key_id = "alias/aws/ssm"
}

# Policy
resource "aws_iam_policy" "GokabotSecretAccess" {
  name = "GokabotSecretAccess"
  path = "/"

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
}

# Role
resource "aws_iam_role" "GokabotTaskExecutionRole" {
  name = "GokabotTaskExecutionRole"
  path = "/"

  assume_role_policy = file("${path.module}/assume_role_policy_ecs_task.json")

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    aws_iam_policy.GokabotSecretAccess.arn
  ]

  tags = {
    cost = var.cost_tag
  }
}

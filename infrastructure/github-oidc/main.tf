terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:23prime/gokabot:*"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "gokabot-github-actions"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  tags = {
    Project = "gokabot"
  }
}

data "aws_iam_policy_document" "lightsail_push" {
  statement {
    actions = [
      "lightsail:CreateContainerServiceRegistryLogin",
      "lightsail:RegisterContainerImage",
      "lightsail:GetContainerImages",
      "lightsail:GetContainerServiceDeployments",
      "lightsail:CreateContainerServiceDeployment",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "lightsail_push" {
  name   = "lightsail-push"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.lightsail_push.json
}

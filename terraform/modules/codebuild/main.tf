# Get KMS Key data
data "aws_kms_key" "s3_key" {
  key_id = "alias/aws/s3"
}

# Get source repository data
data "aws_codecommit_repository" "gokabot" {
  repository_name = var.codecommit_repository_name
}

resource "aws_codebuild_project" "gokabot-build-project" {
  name = "gokabot-build-project"

  build_timeout          = 60
  concurrent_build_limit = 1
  queued_timeout         = 480

  encryption_key = data.aws_kms_key.s3_key.arn
  service_role   = var.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_LARGE"
    image                       = "aws/codebuild/standard:5.0-21.04.23"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      type  = "PLAINTEXT"
      value = var.account_id
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      type  = "PLAINTEXT"
      value = var.region
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      type  = "PLAINTEXT"
      value = var.ecr_repo.name
    }

    environment_variable {
      name  = "IMAGE_TAG"
      type  = "PLAINTEXT"
      value = "latest"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "codebuild-gokabot"
      status      = "ENABLED"
      stream_name = "build-log"
    }
  }

  source_version = "refs/heads/master"

  source {
    type            = "CODECOMMIT"
    location        = data.aws_codecommit_repository.gokabot.clone_url_http
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = false
    }
  }

  tags = {
    Name = "gokabot-build-project"
    cost = var.cost_tag
  }
}

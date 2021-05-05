resource "aws_codepipeline" "gokabot-pipeline" {
  name = "gokabot-pipeline"

  role_arn = var.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = var.s3_bucket.id
  }

  stage {
    name = "Source"

    action {
      category  = "Source"
      name      = "Source"
      namespace = "SourceVariables"

      configuration = {
        "BranchName"           = "master"
        "OutputArtifactFormat" = "CODE_ZIP"
        "PollForSourceChanges" = "false"
        "RepositoryName"       = var.codecommit_repository_name
      }

      input_artifacts  = []
      output_artifacts = ["SourceArtifact"]
      owner            = "AWS"
      provider         = "CodeCommit"
      region           = var.region
      run_order        = 1
      version          = "1"
    }
  }

  stage {
    name = "Build"

    action {
      category  = "Build"
      name      = "Build"
      namespace = "BuildVariables"

      configuration = {
        "ProjectName" = var.build_project.name
      }

      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      owner            = "AWS"
      provider         = "CodeBuild"
      region           = var.region
      run_order        = 1
      version          = "1"
    }
  }

  stage {
    name = "Deploy"

    action {
      category = "Deploy"
      name     = "Deploy"

      configuration = {
        "AppSpecTemplateArtifact"        = "SourceArtifact"
        "AppSpecTemplatePath"            = "appspec.yml"
        "ApplicationName"                = var.deploy_app.name
        "DeploymentGroupName"            = var.deploy_group.deployment_group_name
        "Image1ArtifactName"             = "BuildArtifact"
        "Image1ContainerName"            = "IMAGE1_NAME"
        "TaskDefinitionTemplateArtifact" = "SourceArtifact"
        "TaskDefinitionTemplatePath"     = "taskdef.json"
      }

      input_artifacts  = ["SourceArtifact", "BuildArtifact"]
      output_artifacts = []
      owner            = "AWS"
      provider         = "CodeDeployToECS"
      region           = var.region
      run_order        = 1
      version          = "1"
    }
  }

  tags = {
    Name = "gokabot-pipeline"
    cost = var.cost_tag
  }
}

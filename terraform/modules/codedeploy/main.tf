resource "aws_codedeploy_app" "gokabot-ecs-service-deploy" {
  name             = "gokabot-ecs-service-deploy"
  compute_platform = "ECS"

  tags = {
    Name = "gokabot-ecs-service-deploy"
    cost = var.cost_tag
  }
}

data "aws_sns_topic" "notification-by-gokabot" {
  name = "notification-by-gokabot"
}

resource "aws_codedeploy_deployment_group" "gokabot-ecs-service-deploy-group" {
  deployment_group_name = "gokabot-ecs-service-deploy-group"

  app_name               = aws_codedeploy_app.gokabot-ecs-service-deploy.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  service_role_arn       = var.codedeploy_role.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.ecs_cluster.name
    service_name = var.ecs_service.name
  }

  load_balancer_info {

    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.nlb_listener.arn]
      }

      target_group {
        name = var.tgs[0].name
      }

      target_group {
        name = var.tgs[1].name
      }
    }
  }

  trigger_configuration {
    trigger_events = [
      "DeploymentFailure",
      "DeploymentStart",
      "DeploymentSuccess",
    ]
    trigger_name       = "gokabot-deploy-notification"
    trigger_target_arn = data.aws_sns_topic.notification-by-gokabot.arn
  }

  tags = {
    Name = "gokabot-ecs-service-deploy-group"
    cost = var.cost_tag
  }
}

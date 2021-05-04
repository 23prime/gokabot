resource "aws_ecs_cluster" "gokabot-cluster" {
  name = "gokabot-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Name = "gokabot-cluster"
    cost = var.cost_tag
  }
}

resource "aws_ecs_task_definition" "gokabot-core-api" {
  container_definitions = jsonencode(
    [
      {
        name = "gokabot-core-api"

        image = "${var.ecr_repo.repository_url}:latest"

        command = ["bundle", "exec", "rackup", "app/config.ru", "-o", "0.0.0.0", "-p", "8080"]
        environment = [
          {
            name  = "RACK_ENV"
            value = "production"
          },
          {
            name  = "TZ"
            value = "Asia/Tokyo"
          },
        ]
        essential = true

        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-region        = var.region
            awslogs-group         = var.log_group.name
            awslogs-stream-prefix = var.log_group.name
          }
        }

        portMappings = [
          {
            containerPort = var.container_port
            hostPort      = var.container_port
            protocol      = "tcp"
          },
        ]
        secrets = [
          {
            name      = "DATABASE_URL"
            valueFrom = var.ssm_params.DATABASE_URL.name
          },
          {
            name      = "DISCORD_BOT_TOKEN"
            valueFrom = var.ssm_params.DISCORD_BOT_TOKEN.name
          },
          {
            name      = "DISCORD_TARGET_CHANNEL_ID"
            valueFrom = var.ssm_params.DISCORD_TARGET_CHANNEL_ID.name
          },
          {
            name      = "DISCORD_TARGET_CHANNEL_ID_DEV"
            valueFrom = var.ssm_params.DISCORD_TARGET_CHANNEL_ID_DEV.name
          },
          {
            name      = "GOKABOU_USER_ID"
            valueFrom = var.ssm_params.GOKABOU_USER_ID.name
          },
          {
            name      = "KMT_GROUP_ID"
            valueFrom = var.ssm_params.KMT_GROUP_ID.name
          },
          {
            name      = "LINE_CHANNEL_SECRET"
            valueFrom = var.ssm_params.LINE_CHANNEL_SECRET.name
          },
          {
            name      = "LINE_CHANNEL_TOKEN"
            valueFrom = var.ssm_params.LINE_CHANNEL_TOKEN.name
          },
          {
            name      = "MY_USER_ID"
            valueFrom = var.ssm_params.MY_USER_ID.name
          },
          {
            name      = "NGA_GROUP_ID"
            valueFrom = var.ssm_params.NGA_GROUP_ID.name
          },
          {
            name      = "OPEN_WEATHER_API_KEY"
            valueFrom = var.ssm_params.OPEN_WEATHER_API_KEY.name
          },
        ]
      }
    ]
  )

  cpu                      = "256"
  execution_role_arn       = var.task_execution_role.arn
  family                   = "gokabot-core-api"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  tags = {
    Name = "gokabot-core-api"
    cost = var.cost_tag
  }
}

resource "aws_ecs_service" "gokabot-service" {
  name = "gokabot-service"

  cluster         = aws_ecs_cluster.gokabot-cluster.arn
  task_definition = aws_ecs_task_definition.gokabot-core-api.arn

  desired_count           = 1
  enable_ecs_managed_tags = true
  launch_type             = "FARGATE"
  platform_version        = "1.4.0"

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  load_balancer {
    container_name   = "gokabot-core-api"
    container_port   = var.container_port
    target_group_arn = var.tg.arn
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = [var.sg.id]
    subnets = [
      var.subnets.a.id,
      var.subnets.c.id
    ]
  }

  tags = {
    Name = "gokabot-service"
    cost = var.cost_tag
  }
}

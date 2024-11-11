locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# Task Definition
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${local.name_prefix}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "${var.ecr_repository_url}:${var.container_image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = var.environment_variables
      secrets     = var.secrets
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.frontend.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "frontend"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}${var.health_check_path} || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = local.common_tags
}

# ECS Service
resource "aws_ecs_service" "frontend" {
  name             = "${local.name_prefix}-frontend"
  cluster          = var.ecs_cluster_id
  task_definition  = aws_ecs_task_definition.frontend.arn
  desired_count    = var.desired_count
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.security_group_id]
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "frontend"
    container_port   = var.container_port
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_controller {
    type = "ECS"
  }

  depends_on = [var.alb_listener_arn]

  tags = local.common_tags
}

# Auto Scaling
resource "aws_appautoscaling_target" "frontend" {
  max_capacity       = 6
  min_capacity       = 1
  resource_id        = "service/${data.aws_ecs_cluster.main.cluster_name}/${aws_ecs_service.frontend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "frontend_cpu" {
  name               = "${local.name_prefix}-frontend-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.frontend.resource_id
  scalable_dimension = aws_appautoscaling_target.frontend.scalable_dimension
  service_namespace  = aws_appautoscaling_target.frontend.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70
  }
}

resource "aws_appautoscaling_policy" "frontend_memory" {
  name               = "${local.name_prefix}-frontend-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.frontend.resource_id
  scalable_dimension = aws_appautoscaling_target.frontend.scalable_dimension
  service_namespace  = aws_appautoscaling_target.frontend.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = 70
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/${local.name_prefix}-frontend"
  retention_in_days = 30

  tags = local.common_tags
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "frontend_cpu_high" {
  alarm_name          = "${local.name_prefix}-frontend-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "This metric monitors frontend ECS CPU utilization"
  alarm_actions       = [] # Add SNS topic ARN if needed

  dimensions = {
    ClusterName = data.aws_ecs_cluster.main.cluster_name
    ServiceName = aws_ecs_service.frontend.name
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "frontend_memory_high" {
  alarm_name          = "${local.name_prefix}-frontend-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "This metric monitors frontend ECS memory utilization"
  alarm_actions       = [] # Add SNS topic ARN if needed

  dimensions = {
    ClusterName = data.aws_ecs_cluster.main.cluster_name
    ServiceName = aws_ecs_service.frontend.name
  }

  tags = local.common_tags
}

# Data sources
data "aws_region" "current" {}
data "aws_ecs_cluster" "main" {
  cluster_name = var.ecs_cluster_id
}
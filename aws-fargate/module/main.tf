locals {
  name_prefix = "${var.name}-${var.environment}"
  tags = merge(
    var.tags,
    {
      "Name"        = var.name
      "Environment" = var.environment
    },
  )
}

################################################################################
# ECS Cluster
################################################################################
resource "aws_ecs_cluster" "this" {
  count = var.create_cluster ? 1 : 0

  name = var.cluster_name != "" ? var.cluster_name : "${local.name_prefix}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = local.tags
}

locals {
  # use either the created cluster ARN or the provided existing cluster ARN
  cluster_arn = var.create_cluster ? aws_ecs_cluster.this[0].arn : var.cluster_arn
}

################################################################################
# IAM Roles
################################################################################
# a role is for ECS itself to set up and launch your task
resource "aws_iam_role" "execution" {
  name = "${local.name_prefix}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "execution_policy" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

################################################################################
# CloudWatch Log Groups
################################################################################
resource "aws_cloudwatch_log_group" "service" {
  for_each          = { for service in var.services : service.name => service }
  name              = "/ecs/${local.name_prefix}-${each.value.name}"
  retention_in_days = each.value.log_retention_days
  tags              = local.tags
}

################################################################################
# ECS Task Definitions
################################################################################
resource "aws_ecs_task_definition" "service" {
  for_each                 = { for service in var.services : service.name => service }
  family                   = "${local.name_prefix}-${each.value.name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.task_cpu
  memory                   = each.value.task_memory
  task_role_arn            = aws_iam_role.task.arn
  execution_role_arn       = aws_iam_role.execution.arn

  container_definitions = jsonencode([
    {
      name      = each.value.container_name
      image     = each.value.container_image
      essential = true
      portMappings = each.value.container_port != null ? [
        {
          containerPort = each.value.container_port
          hostPort      = each.value.container_port
          protocol      = "tcp"
        }
      ] : []
      environment = each.value.environment_variables
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.service[each.key].name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = local.tags
}

################################################################################
# ECS Services (for long-running containers)
################################################################################
resource "aws_ecs_service" "service" {
  for_each = { for service in var.services : service.name => service if service.is_service }

  name            = "${local.name_prefix}-${each.value.name}-service"
  cluster         = local.cluster_arn
  task_definition = aws_ecs_task_definition.service[each.key].arn
  desired_count   = each.value.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = each.value.subnet_ids
    security_groups  = [each.value.security_group_id]
    assign_public_ip = each.value.assign_public_ip
  }

  dynamic "load_balancer" {
    for_each = each.value.target_group_arn != null ? [1] : []
    content {
      target_group_arn = each.value.target_group_arn
      container_name   = each.value.container_name
      container_port   = each.value.container_port
    }
  }

  dynamic "deployment_circuit_breaker" {
    for_each = each.value.enable_circuit_breaker != null ? [1] : []
    content {
      enable   = each.value.enable_circuit_breaker
      rollback = each.value.enable_circuit_breaker_rollback
    }
  }

  deployment_controller {
    type = each.value.deployment_controller_type
  }

  tags = local.tags
}
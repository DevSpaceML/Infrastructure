data "aws_ecr_repository" "selfservice" {
  name = "dev/selfservice"
}

# IAM roles for ECS tasks and execution
resource "aws_iam_role" "ecs_execution" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task" {
  name = "ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_ecs_cluster" "slfsvc-cluster" {
  name = "selfservice-app"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "slfsvc-app" {
  family                   = "selfservice-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn  # for app AWS calls

  container_definitions = jsonencode([
    {
      name      = "slfsvc-app"
      image     = "${data.aws_ecr_repository.selfservice.repository_url}:selfservice-20260617-120232"
      essential = true
      portMappings = [{ containerPort = 80, protocol = "tcp" }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/selfservice/nginx"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "slfsvc-app"
        }
      }
    }
  ])
}
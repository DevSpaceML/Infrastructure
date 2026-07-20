data "aws_ecr_repository" "selfservice" {
  name = "dev/selfservice"
}

data "aws_caller_identity" "current" {}


/* CloudWatch Log Group for Nginx */
resource "aws_cloudwatch_log_group" "selfservice_nginx" {
  name              = "/ecs/selfservice/nginx"
  retention_in_days = 14
}

/* ECS IAM Role Trust Policies  */

data "aws_iam_policy_document" "ecs_task_trust" {
  statement {
    sid     = "AllowAssumeRoleEcsTask"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    
    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

  }

}

data "aws_iam_policy_document" "ecs_execution_trust" {
  statement {
    sid = "AllowAssumeRoleEcsExecution"
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

/* Create ecs-execution Role Permissions */

data "aws_iam_policy_document" "ecs_execution_permissions" {
  statement {  
    sid     = "ECRGetAuthToken"
    effect  = "Allow"
    actions = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPullImage"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = [data.aws_ecr_repository.selfservice.arn]
  }

  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups",
    ]
    resources = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/selfservice/nginx:*",
                 "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/selfservice/nginx:log-stream:*"]
  }
}

/* ecs-task permissions  

data "aws_iam_policy_document" "ecs_task_permissions" {
  # No AWS API calls at runtime — GitHub and Postgres are
  # plain TCP/HTTPS connections, not IAM-authenticated.
  #
  # If you later add RDS IAM auth, S3, SQS, etc., add
  # scoped statements here rather than broadening this.
}
*/


# ------------- IAM Roles and Policy Attachments ---------------------- #

# IAM roles for ECS tasks and execution
resource "aws_iam_role" "ecs_exec" {
  name = "task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_execution_trust.json
}

resource "aws_iam_role_policy_attachment" "ecs_exec_managed_policy" {
  role       = aws_iam_role.ecs_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

/*
resource "aws_iam_role_policy" "ecs_execution_policy" {
  name   = "selfservice-execution-policy"
  role   = aws_iam_role.ecs_exec.id
  policy = AmazonECSTaskExecutionRolePolicy
}
*/

resource "aws_iam_role" "ecs_task" {
  name = "ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_trust.json  
}

/*
resource "aws_iam_role_policy" "ecs_task_policy" {
  name = "selfservice-task-policy"
  role = aws_iam_role.ecs_task.id
  policy = data.aws_iam_policy_document.ecs_task_permissions.json
}
*/

# ------------------------------------------------------------------- #

/* ECS Cluster and Tasks */

resource "aws_ecs_cluster" "slfsvc-cluster" {
  name = "selfservice-app-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "slfsvc-app" {
  depends_on = [
    aws_cloudwatch_log_group.selfservice_nginx,
    aws_iam_role_policy_attachment.ecs_exec_managed_policy,
  ]

  family                   = "selfservice-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_exec.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }  

  container_definitions = jsonencode([
    {
      name      = "slfsvc-app"
      image     = "${data.aws_ecr_repository.selfservice.repository_url}:selfservice-20260617-120232"
      essential = true
      portMappings = [{ containerPort = 80, protocol = "tcp" }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.selfservice_nginx.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "slfsvc-app"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "slfsvc-app" {
  name            = "selfservice-app-service"
  cluster         = aws_ecs_cluster.slfsvc-cluster.id
  task_definition = aws_ecs_task_definition.slfsvc-app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_ecs_subnet_ids
    security_groups = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "slfsvc-app"
    container_port   = 80
  }

}




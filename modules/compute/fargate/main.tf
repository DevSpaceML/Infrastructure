data "aws_ecr_repository" "selfservice" {
  name = "dev/selfservice"
}


/* IAM Role Trust Policies  */

data "aws_iam_policy_document" "ecs_task_trust" {
  statement {
    sid     = "AllowAssumeRole-EcsTask"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    
    principals {
      type = "Service"
      identifiers = ["ecs-tasks.awsamazon.com"]
    }

    resources = ["*"]
  }

}

data "aws_iam_policy_document" "ecs_execution_trust" {
  statement {
    sid = "AllowAssumeRole-EcsExecution"
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

/* Role Permissions */

data "aws_iam_policy_document" "ecs-execution" {
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
}

/* IAM Roles and Policy Attachments */
# IAM roles for ECS tasks and execution
resource "aws_iam_role" "ecs-execution" {
  name = "ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_execution_trust.json
}

resource "aws_iam_role_policy" "ecs_execution_policy" {
  name   = "selfservice-execution-policy"
  role   = aws_iam_role.ecs-execution.id
  policy = data.aws_iam_policy_document.ecs-execution.json
}

# ---

resource "aws_iam_role" "ecs_task" {
  name = "ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_trust.json  
}

resource "aws_iam_role_policy" "ecs_task_policy" {
  name = "selfservice-task-policy"
  role = aws_iam_role.ecs_task
  policy = data.aws_iam_policy_document.ecs_task_permissions.json
}



/* ECS Cluster and Tasks */

resource "aws_ecs_cluster" "slfsvc-cluster" {
  name = "selfservice-app-cluster"

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




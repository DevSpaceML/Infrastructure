data "aws_iam_policy_document" "devops_admin_trust" {
  statement {
    sid = "TrustedDevOpsAdmin"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::488347380548:user/SteveB_devops",
        "arn:aws:iam::488347380548:root"
      ]    
    }
    actions = ["sts:AssumeRole"]

  }
}


data "aws_iam_policy_document" "devops_admin" {

  # ──────────────────────────────────────────
  # ECR - Elastic Container Registry
  # ──────────────────────────────────────────
  statement {
    sid    = "ECRFullAccess"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:DeleteRepository",
      "ecr:CreateRepository",
      "ecr:SetRepositoryPolicy",
      "ecr:GetRepositoryPolicy",
      "ecr:TagResource",
      "ecr:UntagResource",
      "ecr:ListTagsForResource",
      "ecr:PutLifecyclePolicy",
      "ecr:GetLifecyclePolicy",
    ]

    resources = ["*"]
  }

  # ──────────────────────────────────────────
  # EKS - Elastic Kubernetes Service
  # ──────────────────────────────────────────
  statement {
    sid    = "EKSFullAccess"
    effect = "Allow"

    actions = [
      "eks:CreateCluster",
      "eks:DeleteCluster",
      "eks:DescribeCluster",
      "eks:ListClusters",
      "eks:UpdateClusterConfig",
      "eks:UpdateClusterVersion",
      "eks:CreateNodegroup",
      "eks:DeleteNodegroup",
      "eks:DescribeNodegroup",
      "eks:ListNodegroups",
      "eks:UpdateNodegroupConfig",
      "eks:UpdateNodegroupVersion",
      "eks:CreateFargateProfile",
      "eks:DeleteFargateProfile",
      "eks:DescribeFargateProfile",
      "eks:ListFargateProfiles",
      "eks:CreateAddon",
      "eks:DeleteAddon",
      "eks:DescribeAddon",
      "eks:ListAddons",
      "eks:UpdateAddon",
      "eks:TagResource",
      "eks:UntagResource",
      "eks:ListTagsForResource",
      "eks:AccessKubernetesApi",
    ]

    resources = ["*"]
  }

  # ──────────────────────────────────────────
  # Fargate - Supporting IAM passrole
  # ──────────────────────────────────────────
  statement {
    sid    = "FargateECSFullAccess"
    effect = "Allow"

    actions = [
      "ecs:CreateCluster",
      "ecs:DeleteCluster",
      "ecs:DescribeClusters",
      "ecs:ListClusters",
      "ecs:CreateService",
      "ecs:DeleteService",
      "ecs:DescribeServices",
      "ecs:ListServices",
      "ecs:UpdateService",
      "ecs:RegisterTaskDefinition",
      "ecs:DeregisterTaskDefinition",
      "ecs:DescribeTaskDefinition",
      "ecs:ListTaskDefinitions",
      "ecs:RunTask",
      "ecs:StopTask",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:PutClusterCapacityProviders",
      "ecs:TagResource",
      "ecs:UntagResource",
      "ecs:ListTagsForResource",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "FargatePassRole"
    effect = "Allow"

    actions = ["iam:PassRole"]

    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"
      values   = [
        "ecs-tasks.amazonaws.com",
        "eks.amazonaws.com",
      ]
    }
  }

  # ──────────────────────────────────────────
  # RDS - Relational Database Service
  # ──────────────────────────────────────────
  statement {
    sid    = "RDSFullAccess"
    effect = "Allow"

    actions = [
      "rds:CreateDBInstance",
      "rds:DeleteDBInstance",
      "rds:DescribeDBInstances",
      "rds:ModifyDBInstance",
      "rds:RebootDBInstance",
      "rds:StartDBInstance",
      "rds:StopDBInstance",
      "rds:CreateDBCluster",
      "rds:DeleteDBCluster",
      "rds:DescribeDBClusters",
      "rds:ModifyDBCluster",
      "rds:StartDBCluster",
      "rds:StopDBCluster",
      "rds:CreateDBSnapshot",
      "rds:DeleteDBSnapshot",
      "rds:DescribeDBSnapshots",
      "rds:RestoreDBInstanceFromDBSnapshot",
      "rds:RestoreDBClusterFromSnapshot",
      "rds:CreateDBSubnetGroup",
      "rds:DeleteDBSubnetGroup",
      "rds:DescribeDBSubnetGroups",
      "rds:ModifyDBSubnetGroup",
      "rds:CreateDBParameterGroup",
      "rds:DeleteDBParameterGroup",
      "rds:DescribeDBParameterGroups",
      "rds:ModifyDBParameterGroup",
      "rds:DescribeDBEngineVersions",
      "rds:ListTagsForResource",
      "rds:AddTagsToResource",
      "rds:RemoveTagsFromResource",
    ]

    resources = ["*"]
  }

  # ──────────────────────────────────────────
  # DynamoDB
  # ──────────────────────────────────────────
  statement {
    sid    = "DynamoDBFullAccess"
    effect = "Allow"

    actions = [
      "dynamodb:CreateTable",
      "dynamodb:DeleteTable",
      "dynamodb:DescribeTable",
      "dynamodb:ListTables",
      "dynamodb:UpdateTable",
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:CreateBackup",
      "dynamodb:DeleteBackup",
      "dynamodb:DescribeBackup",
      "dynamodb:ListBackups",
      "dynamodb:RestoreTableFromBackup",
      "dynamodb:EnableKinesisStreamingDestination",
      "dynamodb:DescribeKinesisStreamingDestination",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:UpdateTimeToLive",
      "dynamodb:DescribeContinuousBackups",
      "dynamodb:UpdateContinuousBackups",
      "dynamodb:ListTagsOfResource",
      "dynamodb:TagResource",
      "dynamodb:UntagResource",
    ]

    resources = ["*"]
  }

  # ──────────────────────────────────────────
  # Supporting services (Logs, CloudWatch)
  # ──────────────────────────────────────────
  statement {
    sid    = "ObservabilityAccess"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:DeleteLogGroup",
      "logs:PutRetentionPolicy",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
    ]

    resources = ["*"]
  }
}
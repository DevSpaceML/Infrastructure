data "aws_iam_policy_document" "deployment_role_trust" {
  statement {
    sid = "AssumeGitHubActions"
    effect = "Allow"
    
    principals {
        type = "Federated"
        identifiers = [
            "arn:aws:iam::488347380548:oidc-provider/token.actions.githubusercontent.com"
        ]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:DevSpaceML/*"]
    }
  }  
}


# -------------------------
# Push images to ECR
# -------------------------

data "aws_iam_policy_document" "deploy_ecr_images" {
  statement {
    sid = "ECR-Authentication"
    effect = "Allow"

    actions = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid = "ECRPushPull"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:DescribeImages",
      "ecr:ListImages",
    ]

    resources = ["arn:aws:488347380548.dkr.ecr.us-east-1.amazonaws.com/dev/selfservice"]
  }
  
}


data "aws_iam_policy_document" "deploy_eks" {
  statement {
  sid = "EksReadAndDeploy"
  effect = "Allow"

  actions = [
      "eks:DescribeCluster",
      "eks:ListClusters",
      "eks:DescribeNodegroup",
      "eks:ListNodegroups",
      "eks:DescribeFargateProfile",
      "eks:ListFargateProfiles",
      "eks:DescribeAddon",
      "eks:ListAddons",
      "eks:AccessKubernetesApi",  # required for kubectl
      "eks:ListTagsForResource",
    ]
  
  resources = ["*"]
  }
}

# -----------------------------
# Deploy and Read ECS, Fargate
# -----------------------------

data "aws_iam_policy_document" "deploy_ecs_fargate" {
  statement {
    sid    = "FargateDeployServices"
    effect = "Allow"

    actions = [
      "ecs:DescribeClusters",
      "ecs:ListClusters",
      "ecs:DescribeServices",
      "ecs:ListServices",
      "ecs:UpdateService",           # scale and redeploy
      "ecs:RegisterTaskDefinition",  # deploy new task revisions
      "ecs:DescribeTaskDefinition",
      "ecs:ListTaskDefinitions",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:RunTask",
      "ecs:StopTask",
      "ecs:ListTagsForResource",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "FargatePassExecutionRole"
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
}

data "aws_iam_policy_document" "deployment_role_policy" {
  source_policy_documents = [
    data.aws_iam_policy_document.deploy_ecr_images.json,
    data.aws_iam_policy_document.deploy_eks.json,
    data.aws_iam_policy_document.deploy_ecs_fargate.json
  ]  
}

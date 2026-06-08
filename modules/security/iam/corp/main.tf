# Corp Roles

# Persistent GHA role-data for deployments
data "aws_iam_role" "github_actions_role" {
  name = "GitHubActionsRole" 
}

# Persistent corp admin-role for manual access and management
data "aws_iam_user" "DevOpsAdmin" {
  user_name = "DevOpsAdmin"
}

# web access role tied to DevOpsAdmin
resource "aws_iam_role" "web_access_role" {
  name = "WebAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = data.aws_iam_user.DevOpsAdmin.arn
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IRSA Karpenter

# OIDC Auth

# Secrets 

# Audit
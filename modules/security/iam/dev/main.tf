# =======================================
# -- IAM resources for DEV environment
# -- Deployment Role, DevOps Admin Role
# =======================================

resource "aws_iam_role" "deployment_role" {
  name = "deployment_role" 
  assume_role_policy = data.aws_iam_policy_document.deployment_role_trust.json
  max_session_duration = 3600

  tags = {
    Role        = "DeploymentRole"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# Persistent Devops admin user for manual access and management
# DevOps Role - tightly permissioned role

resource "aws_iam_role" "devops_admin_role" {
  name = "devops-adminsitrator"
  assume_role_policy = data.aws_iam_policy_document.devops_admin_trust.json
  max_session_duration = 3600

  tags = {
    Role = "DevOpsAdmin"
    Environment = "Dev"
  }
}

/*
resource "aws_iam_role" "developer" {
  name = "Developer"
  assume_role_policy = jsonencode(

  )
}

resource "aws_iam_role" "readonly" {
  name = "ReadOnly"
  assume_role_policy = jsonencode(

  )
}
*/

# --------------------------------   
# Create and attach role policies 
# --------------------------------

# --- devops-admin role policies ---

resource "aws_iam_policy" "devops_admin" {
  name        = "devops-admin-policy"
  description = "DevOps admin access for ECR, EKS, Fargate, RDS, and DynamoDB"
  policy      = data.aws_iam_policy_document.devops_admin.json
}

resource "aws_iam_role_policy_attachment" "devops_admin" {
  role       = aws_iam_role.devops_admin_role.name
  policy_arn = aws_iam_policy.devops_admin.arn
} 

# --- deployment role policies ---

resource "aws_iam_policy" "deployment_role" {
  name = "DeploymentRolePolicy"
  description = "least privilege policy for CI/CD deployments"
  policy      = data.aws_iam_policy_document.deployment_role_policy.json
}

resource "aws_iam_role_policy_attachment" "deployment" {
  role = aws_iam_role.deployment_role.name
  policy_arn = aws_iam_policy.deployment_role.arn
}






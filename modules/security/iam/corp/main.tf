# Corp Roles
# Persistent GHA role-data for deployments

data "aws_iam_role" "deployment_role" {
  name = "deployment_role" 
}

# Persistent corp admin-role for manual access and management
data "aws_iam_user" "DevOpsAdmin" {
  user_name = "SteveB_devops"
}


# OIDC Auth

# Secrets 

# Audit
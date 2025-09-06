# VPC vars
# --------
vpcname  = "dev_vpc"
dev_cidr = "10.0.0.0/16"

# Cluster Vars

clustername = "dev_cluster"
region      = "us-east-1"
k8s_version = "1.29"


# Node group vars

instancetype       = "t3g.medium"
desired_node_count = 3
max_node_count     = 6
min_node_count     = 2


# Access Entries

access_entries = {
  eks_admin_user = {
    principal_arn     = "arn:aws:iam::312907937200:user/devopsadmin"
    kubernetes_groups = ["eks:admin"]
    type              = "STANDARD"
    user_name         = "devops_admin"
    tags = {
      env = "dev"
    }
  }

  k8_admin_role = {
    principal_arn     = "arn:aws:iam::312907937200:role/ClusterAdminRole"
    kubernetes_groups = ["system:masters"]
    type              = "STANDARD"
    user_name         = "role-kubeadmin"
    tags = {
      env = "dev"
    }
  }
}

# IAM Vars

kubeadmin-arn = "arn:aws:iam::312907937200:role/ClusterAdminRole"
devops_user   = "arn:aws:iam::312907937200:user/devopsadmin"


# VPC vars
vpcname  = "dev_vpc"
dev_cidr = "10.0.0.0/16"

# Cluster Vars
clustername = "ML_AI_cluster"
region      = "us-east-1"
k8s_version = "1.29"

# Node group vars
instancetype       = "t3g.medium"
desired_node_count = 3
max_node_count     = 6
min_node_count     = 2


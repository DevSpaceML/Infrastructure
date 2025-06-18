# IAM resources and policies
# IAM Role for the EKS Control Plane, must have AmazonEKSClusterPolicy
# IAM Role for worker Nodes. Policies - AmazonEKSWorkerNodePolicy, AmazonEC2ContainerRegistryReadOnly, AmazonEKS_CNI_Policy
# --------------------------

# IAM Cluster Role
resource "aws_iam_role" "EKS_Cluster_Role" {
	name = "eks-cluster-role"

	assume_role_policy = jsonencode(
		{
			Version = "2012-10-17"
			Statement = [
				{
					Action = [
						"sts:AssumeRole",
						"sts:TagSession"
					]

					Effect = "Allow"
					Principal = {
						Service = "eks.amazonaws.com"
					}
				},
			]
		}
	)  
}

#IAM Node Manager Role
resource "aws_iam_role" "EKS_Node_Manager_Role" {
	name = "node-group-manager"

	assume_role_policy = jsonencode(
	  {
		Version   = "2012-10-17"
		Statement = [
			{
				Action = "sts:AssumeRole"
				Effect = "Allow"
				Principal = {
					Service = "ec2.amazonaws.com"
				}
			},
		]
	 }
    )  
}


resource "aws_iam_role_policy_attachment" "eks_cluster_role_policy" {
	role = aws_iam_role.EKS_Cluster_Role.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "node_manager_policy" {
	role       = aws_iam_role.EKS_Node_Manager_Role.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
	role       = aws_iam_role.EKS_Node_Manager_Role.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_read_only_policy" {
	role       = aws_iam_role.EKS_Node_Manager_Role.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}



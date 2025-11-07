# IAM resources and policies
# IAM Role for the EKS Control Plane, must have AmazonEKSClusterPolicy
# IAM Role for worker Nodes. Policies - AmazonEKSWorkerNodePolicy, AmazonEC2ContainerRegistryReadOnly, AmazonEKS_CNI_Policy
# --------------------------

# data of existing DevOpsAdmin Account

data "aws_iam_user" "DevOpsAdmin" {
  user_name = "DevOpsAdmin"
}

resource "aws_iam_user" "developer" {
  name = "LeadDeveloper"
}

resource "aws_iam_policy" "tech_lead_policy" {
  depends_on = [ aws_iam_user.developer ]
  name = "techleadpolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "sts:AssumeRole",
          "eks:DescribeCluster"
        ]
        Resource = aws_iam_user.developer.arn
      }
    ]
  })
}


resource "aws_iam_user_policy_attachment" "techlead" {
  depends_on = [ aws_iam_policy.tech_lead_policy ]
  user = aws_iam_user.developer.name
  policy_arn = aws_iam_policy.tech_lead_policy.arn 
}


# IAM Cluster Role
resource "aws_iam_role" "eks_cluster_Role" {
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
resource "aws_iam_role" "eks_node_manager_role" {
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
	role = aws_iam_role.eks_cluster_Role.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "node_manager_policy" {
	role       = aws_iam_role.eks_node_manager_role.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
	role       = aws_iam_role.eks_node_manager_role.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_read_only_policy" {
	role       = aws_iam_role.eks_node_manager_role.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}



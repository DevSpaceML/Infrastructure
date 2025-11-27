

module "eks_security_groups" {
  depends_on = [ module.dev_vpc,module.dev_cluster ]
  source     = "../../modules/network/eks-security-groups"
  vpc_id     = module.dev_vpc.eks_vpc_id
  nodegroup_cidr_blocks = module.dev_vpc.nodegroup_pvt_cidr
  clustername = module.dev_cluster.cluster_name
}

module "dev_nodes" {
  depends_on         = [module.dev_cluster, module.iam, module.eks_security_groups]
  source             = "../../modules/compute/eks/nodegroups"
  node_group_mgr_arn = module.iam.node_manager_role_arn
  nodegroupname      = var.nodegroupname
  eksclustername     = module.dev_cluster.cluster_name
  nodegroup_pvt_subnet_id_list = module.dev_vpc.nodegroup_pvt_subnet_id_list
}

data "aws_eks_cluster_auth" "devcluster" {
  name = module.dev_cluster.cluster_name
  depends_on = [ module.dev_cluster ]
}

# Allow provider to be passed from caller
provider "kubernetes" {
  alias                  = "this"
  host                   = module.dev_cluster.cluster_endpoint
  cluster_ca_certificate = module.dev_cluster.cluster_certificate
  token                  = data.aws_eks_cluster_auth.devcluster.token
}

module "auth" {
  depends_on = [module.dev_cluster, module.dev_nodes]

  source         = "../../modules/security/auth"
  eksclustername = module.dev_cluster.cluster_name
  noderolearn    = module.iam.node_manager_role_arn
  clusteradminrole = module.iam.cluster_role_arn
  DevOpsAdminSre   = module.iam.DevOps-SRE-Admin.arn
  techlead         = module.iam.techlead_developer.arn
  hosturl          = module.dev_cluster.cluster_endpoint

  providers = {
    kubernetes = kubernetes.this
  }
}

module "certs" {
  depends_on = [module.dev_cluster, module.auth, module.dev_nodes]

  source             = "../../modules/security/certs"
  security-groups    = module.dev_vpc.eks_security_group_id
  private_cidr_block = module.dev_vpc.private_cidr
  public_cidr_block  = module.dev_vpc.public_cidr
  eks_subnets        = module.dev_vpc.public_subnets
  securitygroupId    = module.dev_vpc.eks_security_group_id
  cluster_vpc_id     = module.dev_vpc.eks_vpc_id
  eksclustername     = module.dev_cluster.cluster_name
}

module "route53" {
  depends_on         = [module.certs]
  source             = "../../modules/dns/route53"
  private_cidr_block = module.dev_vpc.private_cidr
  public_cidr_block  = module.dev_vpc.public_cidr
  securitygroupId    = module.dev_vpc.eks_security_group_id
  ekscertificate     = module.certs.ekscertificate
  certarn            = module.certs.cert_arn
}

module "rds_appdata" {
  depends_on         = [ module.dev_vpc ]
  source             = "../../modules/database/rds"
  rds_subnet_ids = module.dev_vpc.rds_private_subnet_list
}
/* cluster */

output "cluster_name" {
    value  = module.cluster.cluster_name
}

output "cluster_endpoint" {
    value  = module.eks_cluster.cluster_endpoint
}

/* subnets */
output "private_subnet_ids" {
    value  = module.network.private_subnet_ids
}

output "public_subnet_ids" {
    value  = module.network.public_subnet_ids
}

output "nodegroup_pvt_subnet_id_list" {
    value  = module.network.nodegroup_pvt_subnet_id_list
}

output "vpc_id" {
    value  = module.network.vpc_id
}

/* security groups */
output "alb_securitygroup_id" {
    value  = module.cluster.alb_securitygroup_id
}

/* oidc - auth */

output "k8_svc_acc" {
    value  = module.oidc_auth.k8_svc_acc
}

output "ctrlr_role_arn" {
    value  = module.oidc_auth.aws_iam_role_lb_controller_arn
}
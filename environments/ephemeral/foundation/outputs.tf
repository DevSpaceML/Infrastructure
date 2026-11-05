output "cluster_name" {
    value  = module.cluster.cluster_name
}

output "cluster_endpoint" {
    value  = module.cluster.cluster_endpoint
}

output "eks_security_group_id" {
    value  = module.network.eks_security_group_id
}

output "private_subnet_id_list" {
    value  = module.network.private_subnet_id_list
}

output "public_subnet_id_list" {
    value  = module.network.public_subnet_id_list
}

output "nodegroup_pvt_subnet_id_list" {
    value  = module.network.nodegroup_pvt_subnet_id_list
}

output "vpc_id" {
    value  = module.network.vpc_id
}

output "k8_svc_acc" {
    value  = module.oidc_auth.k8_svc_acc
}

output "ctrlr_role_arn" {
    value  = module.oidc_auth.aws_iam_role_lb_controller_arn
}
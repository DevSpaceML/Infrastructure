# Create RBAC Roles and bind to required IAM users / IAM Roles / K8 Service Accounts 

terraform {
  required_version = ">= 1.4.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.36.0"
    }
  }
}

# Check deployment role access to the cluster
resource "terraform_data" "verify_access" {
  triggers_replace = {
	clustername     = var.clustername
	region          = var.region
	deployment_role = var.deployment_role
  }

  provisioner "local-exec" {
	interpreter = ["/bin/bash", "-c"]
	command     =  <<-EOT
	set -euo pipefail
	KubeCfg=$(mktemp)
	"aws eks update-kubeconfig --name ${var.clustername} --region ${var.region} --role-arn ${var.deployment_role} --kubeconfig $KubeCfg"
    for i in $(seq 1 36); do
	  if KUBECONFIG="$KubeCfg" kubectl auth can-i create role -n default | grep -q "yes" && \
         KUBECONFIG="$KubeCfg" kubectl auth can-i create rolebindings -n default | grep -q "yes"; then
		echo "Access verified to the cluster"
		rm -f "$KubeCfg";exit 0
	  else
		echo "Waiting for access to the cluster..."
		sleep 5
	  fi
	done
	rm -f "$KubeCfg"; echo "access verification failed after 3 minutes"; exit 1
	EOT
  }

}

# ClusterRole and Binding
resource "kubernetes_cluster_role_v1" "k8_cluster_role" {
	depends_on = [ terraform_data.verify_access ]
	metadata {
	  name = "K8ClusterAdminRole"	  
	}

	rule {
     api_groups = ["*"]
     resources  = ["*"]
     verbs      = ["get","watch","list","create","update","patch","delete"]
   }   
}

resource "kubernetes_cluster_role_binding_v1" "k8_cluster_role_Binding" {
	depends_on = [ kubernetes_cluster_role_v1.k8_cluster_role ]

	metadata {
	  name = "k8_RoleBinding"
	}

	role_ref {
		api_group = "rbac.authorization.k8s.io"
		kind      =  "ClusterRole"
		name      =  "cluster-admin"
  	}

    subject {
		kind      = "User"
		name      = var.clusteradminrole
		api_group = "rbac.authorization.k8s.io"
    }
  
}

# Developer Role and RoleBinding
resource "kubernetes_role_v1" "Developer" {
  depends_on = [ terraform_data.verify_access ]	

  metadata {
	name = "app-developer"
  }

  rule {
	api_groups = [""]
	resources = ["pods","pods/logs"]
	verbs = ["get","list","watch"]
  }

  rule {
	api_groups = [""]
	resources = ["services"]
	verbs = ["get","list","watch","create","update","patch"]
  }

  rule {
	api_groups = ["apps"]
	resources = ["deployments"]
	verbs = ["get","list","watch","create","update","patch","delete"]
  }

  rule {
	api_groups = [""]
	resources = ["configmaps"]
	verbs = ["get","list","watch","create","update","patch"]
  }

  rule {
	api_groups = [""]
	resources = ["secrets"]
	verbs = ["get","list"]
  }
}

resource "kubernetes_role_binding_v1" "Developer_Role_Binding" {
  depends_on = [ kubernetes_role_v1.Developer ]

  metadata {
	name = "developer-role-binding"
  }

  role_ref {
	api_group = "rbac.authorization.k8s.io"
	kind      = "Role"
	name      = kubernetes_role_v1.Developer.metadata[0].name
  }

  subject {
	kind      = "User"
	name      = var.techlead
	api_group = "rbac.authorization.k8s.io"
  }
}

# DevOps-SRE Role and RoleBinding
resource "kubernetes_role_v1" "Devops-SRE" {
  depends_on = [ terraform_data.verify_access ]
  metadata {
	name = "DevopsSRE"
  }

  rule {
	api_groups = ["apps"]
	resources = ["deployments","statefulsets","daemonsets","replicasets"]
	verbs = ["*"]
  }

  rule {
	api_groups = [""]
	resources = ["pods","pods/log","pods/exec"]
	verbs = ["*"]
  }

  rule {
	api_groups = [""]
	resources = ["configmaps","services","consistentvolumeclaims"]
	verbs = ["*"]
  }

  rule {
	api_groups = [""]
	resources = ["secrets"]
	verbs = ["get","list"]
  }

  rule {
	api_groups = ["batch"]
	resources = ["jobs","cronjobs"]
	verbs = ["*"]
  }

  rule {
	api_groups = [""]
	resources = ["events"]
	verbs = ["get","list","watch"]
  }
}

resource "kubernetes_role_binding_v1" "DevOps_SRE_Role_Binding" {
  depends_on = [ kubernetes_role_v1.Devops-SRE ]

  metadata {
	name = "DevOps-SRE-role-binding"
  }

  role_ref {
	api_group = "rbac.authorization.k8s.io"
	kind      = "Role"
	name      = kubernetes_role_v1.Devops-SRE.metadata[0].name
  }

  subject {
	kind      = "User"
	name      = var.DevOpsAdminSre
	api_group = "rbac.authorization.k8s.io"
  }
}

# Monitoring Role and RoleBinding
resource "kubernetes_cluster_role_v1" "k8monitor" {
  depends_on = [ terraform_data.verify_access ]

  metadata {
	name = "k8_monitor"
  }

  rule {
	api_groups = [""]
	resources = ["nodes","nodes/metrics","nodes/stats","nodes/proxy","pods","services","endpoints"]
	verbs = ["get","list","watch"]
  }

  rule {
	api_groups = ["apps"]
	resources = ["deployments","statefulsets","daemonsets"]
	verbs = ["get","list","watch"]
  }

}
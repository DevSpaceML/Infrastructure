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

# ClusterRole and Binding
resource "kubernetes_cluster_role_v1" "k8_cluster_role" {
	metadata {
	  name = "K8ClusterAdminRole"	  
	}

	rule {
     api_groups = ["*"]
     resources  = ["*"]
     verbs      = ["get","watch","list","create","update","patch","delete"]
   }   
}

resource "kubernetes_cluster_role_binding_v1" "K8_cluster_role_Binding" {
	depends_on = [ kubernetes_cluster_role_v1.k8_cluster_role ]

	metadata {
	  name = "K8_RoleBinding"
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

    subject {
		kind      = "ServiceAccount"
		name      = "deployment"
		namespace = "kube-system"
    }

    subject {
		kind      = "Group"
		name      = "system-masters"
		api_group = "rbac.authorization.k8s.io"
    }
  
}

# Developer Role and RoleBinding

resource "kubernetes_role" "Developer" {

  metadata {
	name = "app-developer"
	namespace = "development"
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

resource "kubernetes_role_binding" "Developer_Role_Binding" {
  depends_on = [ kubernetes_role.Developer ]

  metadata {
	name = "developer-role-binding"
	namespace = "development"
  }

  role_ref {
	api_group = "rbac.authorization.k8s.io"
	kind      = "Role"
	name      = kubernetes_role.Developer.metadata[0].name
  }

  subject {
	kind      = "User"
	name      = var.techlead
	api_group = "rbac.authorization.k8s.io"
  }
}

# DevOps-SRE Role and RoleBinding

resource "kubernetes_role" "Devops-SRE" {
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

resource "kubernetes_role_binding" "DevOps_SRE_Role_Binding" {
  depends_on = [ kubernetes_role.Devops-SRE ]

  metadata {
	name = "DevOps-SRE-role-binding"
  }

  role_ref {
	api_group = "rbac.authorization.k8s.io"
	kind      = "Role"
	name      = kubernetes_role.Devops-SRE.metadata[0].name
  }

  subject {
	kind      = "User"
	name      = var.DevOpsAdminSre
	api_group = "rbac.authorization.k8s.io"
  }
}

# Monitoring Role and RoleBinding

resource "kubernetes_cluster_role" "K8_monitor" {
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
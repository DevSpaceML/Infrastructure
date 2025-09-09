terraform {
  required_version = ">= 1.4.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.36.0"
    }
  }
}

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

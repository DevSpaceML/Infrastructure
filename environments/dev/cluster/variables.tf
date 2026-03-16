variable "clustername" {
  description = "name of the dev cluster"
  type        = string
}


variable "cluster_subnet_id_list" {
  description = "list of subnet ids for the cluster"
  type        = list(string)
}
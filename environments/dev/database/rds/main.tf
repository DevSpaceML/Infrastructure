
module "rds_appdata" {
  source             = "../../../../modules/database/rds"
  rds_subnet_ids     = data.terraform_remote_state.dev_vpc.outputs.db_subnet_id_list
}
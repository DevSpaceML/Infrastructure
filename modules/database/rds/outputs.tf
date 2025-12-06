output "dataeng_userId"{
	value = aws_iam_user.data_engineer.unique_id
}

output "db_instance_endpoint" {
  value = aws_db_instance.appdata_mysql.endpoint
}

output "db_instance_address" {
  value = aws_db_instance.appdata_mysql.address
}
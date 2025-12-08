
resource "aws_db_subnet_group" "k8_db_subnet_group" {
    name = "k8_db_subnets"
	subnet_ids = var.rds_subnet_ids
	tags = {
		Name = "k8_db_subnets"
	}
}

resource "aws_db_instance" "appdata_mysql"{
	depends_on = [ aws_db_subnet_group.k8_db_subnet_group ]

	allocated_storage 		 = 10
	db_name			  		 = "tiyeni"
	identifier				 = "dataeast_mysql"
	engine 			  		 = "mysql"
	engine_version 	  		 = "8.0"
	instance_class    		 = "db.t3.micro"
	username		  		 = "root"
	password 		  		 = "Falc0nC0ll3g3!"
	parameter_group_name     = "default.MySql8.0"
	skip_final_snapshot		 = true
	backup_retention_period  = 7
	db_subnet_group_name	 = aws_db_subnet_group.k8_db_subnet_group.name
	multi_az				 = true
	iam_database_authentication_enabled = true					
}

resource "aws_db_instance" "replica-appdata_mysql"{
	replicate_source_db     = aws_db_instance.appdata_mysql.identifier
	instance_class          = "db.t3.micro"
	skip_final_snapshot     = true
	backup_retention_period = 7
	multi_az                = true

	depends_on = [ aws_db_instance.appdata_mysql ]
}

resource "aws_db_snapshot" "appdata_mysql"{
	db_instance_identifier = aws_db_instance.appdata_mysql.identifier
	db_snapshot_identifier = "SnapshotAppDataMySql"

	depends_on = [ aws_db_instance.appdata_mysql ]
}

resource "aws_iam_policy" "policy_dbEast_Readonly"{
	name = "dbEastReadOnly"
	description = "IAM policy granting read access to appdata_mysql"
	policy = jsonencode({
	  Version = "2012-10-17"	
	  Statement = [
	  	{
	  		Action = [
			 "rds:DescribeDBInstances",
			 "rds:ListTagsForResource"		  		 	
	  		],
	  		Effect   = "Allow",
	  		Resource = "*"
	  	}
	  ]
	})
}

resource "aws_iam_role" "role_dbeastreadonly"{
	name = "appdata_mysqlReadOnly"
	assume_role_policy = jsonencode({
			  Version = "2012-10-17"
			  Statement = [
			    {
			    	Action = "sts:AssumeRole"
			    	Effect = "Allow",
			    	Principal = {
			    		Service = "ec2.amazonaws.com"
			    	}
			    }
			  ]
			})
}

resource "aws_iam_role_policy_attachment" "attach_policy_dbEast_ReadOnly" {
	role       = aws_iam_role.role_dbeastreadonly.name
	policy_arn = aws_iam_policy.policy_dbEast_Readonly.arn
}

resource "aws_iam_user" "data_engineer" {
	name = "DataEngineer"
}

resource "aws_iam_policy" "policy_dbadminaccess" {
	name = "dbEastAccessPolicy"
	path = "/"
	description = "iam policy for read-write access to mysql database"
	policy = jsonencode({
		  Version = "2012-10-17"		
		  Statement = [
        	{
        		Effect = "Allow",
        		Action = [
        		 "rds-db:connect",	
        		],
        		Resource = "arn:aws:rds-db:us-east-1:${var.iamaccountid}:data_engineer:dataeast/data_engineer"
        	}
		  ]
	 })	
}


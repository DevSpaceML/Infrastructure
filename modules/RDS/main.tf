resource "aws_db_instance" "mysqleast"{
	allocated_storage 		 = 10
	db_name			  		 = "customers"
	identifier				 = "dataeast"
	engine 			  		 = "mysql"
	engine_version 	  		 = "8.0"
	instance_class    		 = "db.t3.micro"
	username		  		 = "inkeymgmtstore"
	password 		  		 = "pwinkeymgmtstore"
	parameter_group_name     = "default.MySql8.0"
	skip_final_snapshot		 = true
	backup_retention_period  = 7
	db_subnet_group_name	 = var.db_subnet_group_name
	multi_az				 = true	
	iam_database_authentication_enabled = true					
}

resource "aws_db_instance" "replica-mysqleast"{
	replicate_source_db     = aws_db_instance.mysqleast.identifier
	instance_class          = "db.t3.micro"
	skip_final_snapshot     = true
	backup_retention_period = 7
}

resource "aws_db_snapshot" "mysqleast"{
	db_instance_identifier = aws_db_instance.mysqleast.identifier
	db_snapshot_identifier = "snapshot-mysqleast"
}

resource "aws_iam_policy" "policy_dbEast_Readonly"{
	name = "dbEastReadOnly"
	description = "IAM policy granting read access to mysqleast"
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
	name = "MySQlEastReadOnly"
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

output "dataeng_userId"{
	value = aws_iam_user.data_engineer.unique_id
}

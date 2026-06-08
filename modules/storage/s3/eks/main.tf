resource "aws_s3_bucket" "shared_s3_storage" {
  bucket = "${var.projectname}-${var.environment}-shared-storage-${local.bucket_suffix}"

  tags = merge(local.common_tags, {
    Name      = "S3_shared_storage"
    Purpose   = "General application storage"
    DataClass = "Internal"    
  })
}

resource "aws_s3_bucket" "audit_logs" {
    bucket = "${var.projectname}-${var.environment}-audit-logs.${local.bucket_suffix}"

    tags = merge(local.common_tags,{
      Name      = "Audit and logs"
      Purpose   = "Store Audit and application logs"
      DataClass = "Internal"
    })
}

resource "aws_s3_bucket" "iac_state_files" {
  bucket = "${var.projectname}-${var.environment}-terraform-state.${local.bucket_suffix}"

  tags =  merge(local.common_tags,{
    Name           = "terraform state files"
    Purpose        = "IAC state mgmt"
    DataClass      = "Critical"
    BackupRequired = true
  })
}

resource "aws_s3_bucket" "app_artifacts" {
    bucket = "${var.projectname}-${var.environment}-app-artifacts.${local.bucket_suffix}"
    tags = merge(local.common_tags{
      Name      = "Application Artifacts"
      Purpose   = "Stores build artifacts and deployments"
      DataClass = "Internal"
    })  
}

resource "aws_s3_bucket" "backups" {
      bucket = "${var.projectname}-${var.environment}-backups.${local.bucket_suffix}"
      tags = merge(local.common_tags,{
      Name = "Data Backup"
      Purpose = "Data Backups and Disaster Recovery"
      RetentionPeriod = "${var.backup_retention} days"
    })
}

resource "aws_s3_bucket" "static_assets" {
    bucket = "${var.projectname}-${var.environment}-static-assets.${local.bucket_suffix}"
    tags = merge(local.common_tags,{
      Name      = "Static Assets"
      Purpose   = "WebDev Static Assets"
      DataClass = "Public"
    })  
}

# S3 Access Settings 
resource "aws_s3_bucket_public_access_block" "app_artifacts" {
  bucket = aws_s3_bucket.app_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "audit_logs" {
  bucket = aws_s3_bucket.audit_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "shared_s3_storage" {
  bucket = aws_s3_bucket.shared_s3_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Security Config-Versioning





resource "aws_s3_bucket" "tfStateFiles" {
  bucket = "dev-terraform-state-586098609239"

  tags = {
    Environment = "dev"
    Project = "gemmapp"
  }
}

resource "aws_s3_bucket_versioning" "tfStateFiles" {
  bucket = aws_s3_bucket.tfStateFiles.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfStateFiles" {
  bucket = aws_s3_bucket.tfStateFiles.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfStateFiles" {
  bucket = aws_s3_bucket.tfStateFiles.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "tfStateFiles" {
  bucket = aws_s3_bucket.tfStateFiles.id

  target_bucket = aws_s3_bucket.tfStateFiles.id
  target_prefix = "logs/"
}

resource "aws_s3_bucket_lifecycle_configuration" "tfStateFiles" {
  bucket = aws_s3_bucket.tfStateFiles.id

  rule {
    id = "delete-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

# inlcude dynanmo_db table for tf state locks when ready
# Backend Infrastructure Setup
# This creates the S3 bucket and DynamoDB table needed for Terraform state storage
# Run this first: terraform init && terraform apply -target=aws_s3_bucket.terraform_state

# S3 Bucket for Terraform State
resource "aws_s3_bucket" "terraform_state" {
  bucket = "thrive-cluster-test-terraform-state"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "dev"
    Project     = "Thrive_Cluster_Test"
    Purpose     = "Terraform State Storage"
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB Table for State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name           = "thrive-cluster-test-terraform-locks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Locks"
    Environment = "dev"
    Project     = "Thrive_Cluster_Test"
    Purpose     = "Terraform State Locking"
  }
}

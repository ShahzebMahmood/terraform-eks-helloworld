# Terraform Backend Configuration
# This stores the state file in S3 for persistence and team collaboration

terraform {
  backend "s3" {
    # S3 bucket for storing Terraform state
    bucket = "thrive-cluster-test-terraform-state"
    
    # Key (path) for the state file
    key = "terraform.tfstate"
    
    # AWS region
    region = "us-east-1"
    
    # Enable state locking with DynamoDB
    dynamodb_table = "thrive-cluster-test-terraform-locks"
    
    # Enable encryption
    encrypt = true
    
    # Optional: versioning for state file
    versioning = true
  }
}

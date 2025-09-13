#!/bin/bash

# Setup Terraform Backend Infrastructure
# This script creates the S3 bucket and DynamoDB table for Terraform state storage

set -e

echo "🚀 Setting up Terraform Backend Infrastructure"
echo "=============================================="

# Check if AWS CLI is configured
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "❌ AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

echo "✅ AWS CLI configured"

# Get AWS account ID and region
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region || echo "us-east-1")

echo "📊 AWS Account ID: $AWS_ACCOUNT_ID"
echo "🌍 AWS Region: $AWS_REGION"

# Check if backend infrastructure already exists
echo ""
echo "🔍 Checking if backend infrastructure already exists..."

# Check S3 bucket
if aws s3api head-bucket --bucket "thrive-cluster-test-terraform-state" 2>/dev/null; then
    echo "✅ S3 bucket 'thrive-cluster-test-terraform-state' already exists"
    BUCKET_EXISTS=true
else
    echo "⚠️ S3 bucket 'thrive-cluster-test-terraform-state' does not exist"
    BUCKET_EXISTS=false
fi

# Check DynamoDB table
if aws dynamodb describe-table --table-name "thrive-cluster-test-terraform-locks" --region $AWS_REGION >/dev/null 2>&1; then
    echo "✅ DynamoDB table 'thrive-cluster-test-terraform-locks' already exists"
    TABLE_EXISTS=true
else
    echo "⚠️ DynamoDB table 'thrive-cluster-test-terraform-locks' does not exist"
    TABLE_EXISTS=false
fi

# Create backend infrastructure if needed
if [ "$BUCKET_EXISTS" = false ] || [ "$TABLE_EXISTS" = false ]; then
    echo ""
    echo "🏗️ Creating backend infrastructure..."
    
    # Initialize Terraform for backend setup
    echo "📦 Initializing Terraform for backend setup..."
    terraform init -backend=false
    
    # Apply backend infrastructure
    echo "🚀 Creating S3 bucket and DynamoDB table..."
    terraform apply -target=aws_s3_bucket.terraform_state -target=aws_s3_bucket_versioning.terraform_state -target=aws_s3_bucket_server_side_encryption_configuration.terraform_state -target=aws_s3_bucket_public_access_block.terraform_state -target=aws_dynamodb_table.terraform_locks -auto-approve
    
    echo "✅ Backend infrastructure created successfully!"
else
    echo "✅ Backend infrastructure already exists - skipping creation"
fi

echo ""
echo "🔄 Migrating to S3 backend..."

# Check if we have existing state
if [ -f "terraform.tfstate" ] && [ -s "terraform.tfstate" ]; then
    echo "📁 Found existing state file"
    
    # Check if state has resources
    if terraform state list >/dev/null 2>&1; then
        echo "📋 Found resources in existing state"
        echo "🔄 Migrating state to S3 backend..."
        
        # Initialize with S3 backend
        terraform init -migrate-state
        
        echo "✅ State migrated to S3 backend successfully!"
    else
        echo "⚠️ Existing state file is empty"
        echo "🔄 Initializing with S3 backend..."
        
        # Initialize with S3 backend
        terraform init
        
        echo "✅ Initialized with S3 backend!"
    fi
else
    echo "⚠️ No existing state file found"
    echo "🔄 Initializing with S3 backend..."
    
    # Initialize with S3 backend
    terraform init
    
    echo "✅ Initialized with S3 backend!"
fi

echo ""
echo "🎉 Terraform Backend Setup Complete!"
echo "===================================="
echo "✅ S3 bucket: thrive-cluster-test-terraform-state"
echo "✅ DynamoDB table: thrive-cluster-test-terraform-locks"
echo "✅ State file: Now stored in S3"
echo "✅ State locking: Enabled with DynamoDB"
echo ""
echo "💡 Next steps:"
echo "   1. Run 'terraform plan' to see what will be created"
echo "   2. Run 'terraform apply' to create your infrastructure"
echo "   3. State will be automatically saved to S3"
echo ""
echo "🔒 Security:"
echo "   - State file is encrypted in S3"
echo "   - State locking prevents concurrent modifications"
echo "   - Bucket has public access blocked"

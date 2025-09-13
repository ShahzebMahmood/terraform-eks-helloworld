#!/bin/bash

# Deploy with State Backup Script
# This script runs terraform apply and backs up the state file even if it fails

set -e

echo "🚀 Terraform Deploy with State Backup"
echo "====================================="
echo ""

# Check if we're in a terraform directory
if [ ! -f "main.tf" ] || [ ! -f "terraform.tfvars" ]; then
    echo "❌ Error: Not in a Terraform directory"
    echo "Please run this script from the project root directory"
    exit 1
fi

# Create backup directory
BACKUP_DIR="terraform-state-backups"
mkdir -p "$BACKUP_DIR"

# Generate timestamp for backup
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/terraform.tfstate.backup_$TIMESTAMP"

echo "🔧 Initializing Terraform..."
terraform init

echo "📋 Validating Terraform configuration..."
terraform validate

echo "📊 Creating Terraform plan..."
terraform plan \
  -var="github_repo=ShahzebMahmood/TF_AWS_Test" \
  -var="aws_access_key_id=AKIAWN4EPLGU5W3XMKDH" \
  -var="aws_secret_access_key=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" \
  -out=tfplan

echo "🚀 Applying Terraform configuration..."
if terraform apply \
  -var="github_repo=ShahzebMahmood/TF_AWS_Test" \
  -var="aws_access_key_id=AKIAWN4EPLGU5W3XMKDH" \
  -var="aws_secret_access_key=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" \
  -auto-approve; then
    echo "✅ Terraform apply completed successfully!"
    
    # Backup successful state
    if [ -f "terraform.tfstate" ]; then
        cp terraform.tfstate "$BACKUP_FILE"
        echo "💾 State file backed up to: $BACKUP_FILE"
    fi
else
    echo "❌ Terraform apply failed!"
    
    # Backup failed state (if any resources were created)
    if [ -f "terraform.tfstate" ]; then
        cp terraform.tfstate "$BACKUP_FILE"
        echo "💾 Partial state file backed up to: $BACKUP_FILE"
        echo "🧹 You can now run: ./scripts/cleanup-partial-deployment.sh"
    else
        echo "ℹ️ No state file found - deployment failed before any resources were created"
    fi
    
    exit 1
fi

echo ""
echo "🎯 Deployment Summary"
echo "===================="
echo "✅ Infrastructure deployed successfully"
echo "💾 State file backed up to: $BACKUP_FILE"
echo "🚀 Your application should now be running!"
echo ""
echo "📊 To check deployment status:"
echo "   kubectl get pods -l app=hello-world"
echo "   kubectl get services"
echo "   kubectl get ingress"

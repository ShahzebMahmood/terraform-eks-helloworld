#!/bin/bash

# Quick Terraform Destroy Script
# This script runs terraform destroy to clean up all resources

set -e

echo "🧹 Terraform Destroy Script"
echo "=========================="
echo ""

# Check if we're in a terraform directory
if [ ! -f "main.tf" ] || [ ! -f "terraform.tfvars" ]; then
    echo "❌ Error: Not in a Terraform directory"
    echo "Please run this script from the project root directory"
    exit 1
fi

echo "🔍 Checking Terraform state..."

# Initialize terraform if needed
if [ ! -d ".terraform" ]; then
    echo "🔧 Initializing Terraform..."
    terraform init
fi

# Check if we have any resources in state
if terraform state list 2>/dev/null | grep -q .; then
    echo "📋 Found resources in Terraform state:"
    terraform state list
    echo ""
    
    # Confirm destruction
    echo "⚠️  WARNING: This will destroy ALL resources managed by Terraform!"
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️ Running terraform destroy..."
        terraform destroy -auto-approve
        echo "✅ Terraform destroy completed successfully!"
    else
        echo "❌ Terraform destroy cancelled"
        exit 0
    fi
else
    echo "ℹ️ No resources found in Terraform state"
    echo "Nothing to destroy"
fi

echo ""
echo "🎯 Summary"
echo "=========="
echo "✅ Terraform destroy completed"
echo "💡 You can now run the deployment workflow safely"
echo "🚀 Run: Go to GitHub Actions and trigger the deploy workflow"

#!/bin/bash

# Cleanup Existing AWS Resources Script
# This script removes existing AWS resources that may conflict with new deployments
# Uses terraform destroy as the primary method, with manual cleanup as fallback

set -e

# Configuration
AWS_REGION="us-east-1"
CLUSTER_NAME="thrive-cluster-test"
ECR_REPOSITORY="hello-world"
PROJECT_TAG="Thrive_Cluster_Test"

echo "🧹 AWS Resource Cleanup Script"
echo "=============================="
echo "Region: $AWS_REGION"
echo "Cluster: $CLUSTER_NAME"
echo "ECR Repository: $ECR_REPOSITORY"
echo ""

# Function to confirm deletion
confirm_deletion() {
    local resource_type="$1"
    local resource_name="$2"
    
    echo "⚠️  Found existing $resource_type: $resource_name"
    read -p "Do you want to delete it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

echo "🔍 Step 1: Attempting Terraform Destroy"
echo "======================================="

# Check if we're in a terraform directory
if [ -f "main.tf" ] && [ -f "terraform.tfvars" ]; then
    echo "📋 Found Terraform configuration, attempting terraform destroy..."
    
    # Initialize terraform if needed
    if [ ! -d ".terraform" ]; then
        echo "🔧 Initializing Terraform..."
        terraform init
    fi
    
    # Check if we have any resources in state
    if terraform state list 2>/dev/null | grep -q .; then
        echo "📋 Found resources in Terraform state, destroying them..."
        terraform destroy -auto-approve
        echo "✅ Terraform destroy completed"
    else
        echo "ℹ️ No resources found in Terraform state"
    fi
else
    echo "⚠️ No Terraform configuration found, skipping terraform destroy"
fi

echo ""
echo "🔍 Step 2: Manual Cleanup of Remaining Resources"
echo "================================================"

# Check and clean up ECR repository
if aws ecr describe-repositories --repository-names $ECR_REPOSITORY --region $AWS_REGION 2>/dev/null; then
    if confirm_deletion "ECR repository" "$ECR_REPOSITORY"; then
        echo "🗑️ Deleting ECR repository and images..."
        # Delete all images first
        IMAGES=$(aws ecr list-images --repository-name $ECR_REPOSITORY --region $AWS_REGION --query 'imageIds[*]' --output json 2>/dev/null || echo '[]')
        if [ "$IMAGES" != "[]" ] && [ "$IMAGES" != "null" ]; then
            aws ecr batch-delete-image --repository-name $ECR_REPOSITORY --region $AWS_REGION --image-ids "$IMAGES"
        fi
        # Delete repository
        aws ecr delete-repository --repository-name $ECR_REPOSITORY --region $AWS_REGION --force
        echo "✅ ECR repository deleted"
    fi
else
    echo "✅ ECR repository does not exist"
fi

# Check and clean up EKS cluster
if aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION 2>/dev/null; then
    if confirm_deletion "EKS cluster" "$CLUSTER_NAME"; then
        echo "🗑️ Deleting EKS cluster..."
        # Delete node groups first
        NODE_GROUPS=$(aws eks list-nodegroups --cluster-name $CLUSTER_NAME --region $AWS_REGION --query 'nodegroups' --output text 2>/dev/null || echo "")
        if [ -n "$NODE_GROUPS" ] && [ "$NODE_GROUPS" != "None" ]; then
            for nodegroup in $NODE_GROUPS; do
                echo "🗑️ Deleting node group: $nodegroup"
                aws eks delete-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name $nodegroup --region $AWS_REGION
            done
            echo "⏳ Waiting for node groups to be deleted..."
            sleep 60
        fi
        # Delete cluster
        aws eks delete-cluster --name $CLUSTER_NAME --region $AWS_REGION
        echo "✅ EKS cluster deleted"
    fi
else
    echo "✅ EKS cluster does not exist"
fi

# Check and clean up IAM roles
for role in "thrive-cluster-test-cluster-role" "thrive-cluster-test-node-role" "thrive-cluster-test-github-actions-role" "hello-world-pod-role"; do
    if aws iam get-role --role-name $role --region $AWS_REGION 2>/dev/null; then
        if confirm_deletion "IAM role" "$role"; then
            echo "🗑️ Deleting IAM role: $role"
            # Detach policies first
            aws iam list-attached-role-policies --role-name $role --query 'AttachedPolicies[*].PolicyArn' --output text | xargs -I {} aws iam detach-role-policy --role-name $role --policy-arn {} 2>/dev/null || echo "No policies to detach"
            # Delete role
            aws iam delete-role --role-name $role --region $AWS_REGION
            echo "✅ IAM role deleted: $role"
        fi
    else
        echo "✅ IAM role does not exist: $role"
    fi
done

# Check and clean up Secrets Manager secrets
for secret in "thrive-cluster-test-github-actions-credentials" "thrive-cluster-test-app-secrets"; do
    if aws secretsmanager describe-secret --secret-id $secret --region $AWS_REGION 2>/dev/null; then
        if confirm_deletion "Secret" "$secret"; then
            echo "🗑️ Deleting secret: $secret"
            aws secretsmanager delete-secret --secret-id $secret --region $AWS_REGION --force-delete-without-recovery
            echo "✅ Secret deleted: $secret"
        fi
    else
        echo "✅ Secret does not exist: $secret"
    fi
done

# Check and clean up CloudWatch log groups
if aws logs describe-log-groups --log-group-name-prefix "/aws/eks/$CLUSTER_NAME" --region $AWS_REGION --query 'logGroups[0].logGroupName' --output text 2>/dev/null | grep -q "$CLUSTER_NAME"; then
    if confirm_deletion "CloudWatch log group" "/aws/eks/$CLUSTER_NAME/cluster"; then
        echo "🗑️ Deleting CloudWatch log group..."
        aws logs delete-log-group --log-group-name "/aws/eks/$CLUSTER_NAME/cluster" --region $AWS_REGION
        echo "✅ CloudWatch log group deleted"
    fi
else
    echo "✅ CloudWatch log group does not exist"
fi

# Check and clean up OIDC providers
OIDC_PROVIDERS=$(aws iam list-open-id-connect-providers --region $AWS_REGION --query 'OpenIDConnectProviderList[?contains(Arn, `thrive-cluster-test`)].Arn' --output text 2>/dev/null || echo "")
if [ -n "$OIDC_PROVIDERS" ]; then
    for provider in $OIDC_PROVIDERS; do
        if confirm_deletion "OIDC provider" "$provider"; then
            echo "🗑️ Deleting OIDC provider: $provider"
            aws iam delete-open-id-connect-provider --open-id-connect-provider-arn "$provider" --region $AWS_REGION
            echo "✅ OIDC provider deleted"
        fi
    done
else
    echo "✅ No OIDC providers found"
fi

# Check and clean up VPC resources
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Project,Values=$PROJECT_TAG" --query 'Vpcs[0].VpcId' --output text --region $AWS_REGION 2>/dev/null || echo "None")
if [ "$VPC_ID" != "None" ] && [ "$VPC_ID" != "null" ]; then
    if confirm_deletion "VPC" "$VPC_ID"; then
        echo "🗑️ Deleting VPC and related resources..."
        # Delete subnets
        SUBNETS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[*].SubnetId' --output text --region $AWS_REGION 2>/dev/null || echo "")
        if [ -n "$SUBNETS" ]; then
            for subnet in $SUBNETS; do
                echo "🗑️ Deleting subnet: $subnet"
                aws ec2 delete-subnet --subnet-id $subnet --region $AWS_REGION
            done
        fi
        # Delete internet gateway
        IGW_ID=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query 'InternetGateways[0].InternetGatewayId' --output text --region $AWS_REGION 2>/dev/null || echo "None")
        if [ "$IGW_ID" != "None" ] && [ "$IGW_ID" != "null" ]; then
            echo "🗑️ Detaching and deleting internet gateway: $IGW_ID"
            aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID --region $AWS_REGION
            aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID --region $AWS_REGION
        fi
        # Delete VPC
        aws ec2 delete-vpc --vpc-id $VPC_ID --region $AWS_REGION
        echo "✅ VPC and related resources deleted"
    fi
else
    echo "✅ VPC does not exist"
fi

echo ""
echo "🎯 Cleanup Summary"
echo "=================="
echo "✅ All existing resources have been checked"
echo "💡 You can now run the deployment workflow safely"
echo "🚀 Run: Go to GitHub Actions and trigger the deploy workflow"
echo ""
echo "📊 To verify cleanup, run: ./scripts/verify-aws-cleanup.sh"

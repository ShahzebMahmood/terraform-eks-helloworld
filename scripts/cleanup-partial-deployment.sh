#!/bin/bash

# Cleanup Partial Deployment Script
# This script handles the case where Terraform deployment fails partway through
# leaving some resources in the state file and some created in AWS

set -e

echo "🧹 Partial Deployment Cleanup Script"
echo "===================================="
echo ""

# Check if we're in a terraform directory
if [ ! -f "main.tf" ] || [ ! -f "terraform.tfvars" ]; then
    echo "❌ Error: Not in a Terraform directory"
    echo "Please run this script from the project root directory"
    exit 1
fi

echo "🔍 Step 1: Check Terraform State"
echo "================================"

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
    
    echo "🔍 Step 2: Attempt Terraform Destroy"
    echo "===================================="
    echo "🗑️ Running terraform destroy to clean up resources in state..."
    
    # Try to destroy resources in state
    if terraform destroy -auto-approve; then
        echo "✅ Terraform destroy completed successfully"
    else
        echo "⚠️ Terraform destroy failed - some resources may need manual cleanup"
        echo "📋 Resources still in state:"
        terraform state list 2>/dev/null || echo "No resources in state"
    fi
else
    echo "ℹ️ No resources found in Terraform state"
fi

echo ""
echo "🔍 Step 3: Manual Cleanup of Any Remaining Resources"
echo "===================================================="

AWS_REGION="us-east-1"
CLUSTER_NAME="thrive-cluster-test"
ECR_REPOSITORY="hello-world"

# Function to check and delete resource
check_and_delete() {
    local resource_type="$1"
    local resource_name="$2"
    local delete_command="$3"
    
    echo "🔍 Checking $resource_type: $resource_name"
    if eval "$delete_command" 2>/dev/null; then
        echo "✅ $resource_type exists and will be deleted"
        return 0
    else
        echo "ℹ️ $resource_type does not exist"
        return 1
    fi
}

# Clean up ECR repository
if check_and_delete "ECR repository" "$ECR_REPOSITORY" "aws ecr describe-repositories --repository-names $ECR_REPOSITORY --region $AWS_REGION"; then
    echo "🗑️ Deleting ECR repository and images..."
    # Delete all images first
    IMAGES=$(aws ecr list-images --repository-name $ECR_REPOSITORY --region $AWS_REGION --query 'imageIds[*]' --output json 2>/dev/null || echo '[]')
    if [ "$IMAGES" != "[]" ] && [ "$IMAGES" != "null" ]; then
        aws ecr batch-delete-image --repository-name $ECR_REPOSITORY --region $AWS_REGION --image-ids "$IMAGES" || echo "⚠️ Some images may have already been deleted"
    fi
    # Delete repository
    aws ecr delete-repository --repository-name $ECR_REPOSITORY --region $AWS_REGION --force || echo "⚠️ Repository may have already been deleted"
    echo "✅ ECR repository deleted"
fi

# Clean up EKS cluster
if check_and_delete "EKS cluster" "$CLUSTER_NAME" "aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION"; then
    echo "🗑️ Deleting EKS cluster..."
    # Delete node groups first
    NODE_GROUPS=$(aws eks list-nodegroups --cluster-name $CLUSTER_NAME --region $AWS_REGION --query 'nodegroups' --output text 2>/dev/null || echo "")
    if [ -n "$NODE_GROUPS" ] && [ "$NODE_GROUPS" != "None" ]; then
        for nodegroup in $NODE_GROUPS; do
            echo "  🗑️ Deleting node group: $nodegroup"
            aws eks delete-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name $nodegroup --region $AWS_REGION || echo "  ⚠️ Node group may have already been deleted"
        done
        echo "  ⏳ Waiting for node groups to be deleted..."
        sleep 60
    fi
    # Delete cluster
    aws eks delete-cluster --name $CLUSTER_NAME --region $AWS_REGION || echo "⚠️ Cluster may have already been deleted"
    echo "✅ EKS cluster deleted"
fi

# Clean up IAM roles
for role in "thrive-cluster-test-cluster-role" "thrive-cluster-test-node-role" "thrive-cluster-test-github-actions-role" "hello-world-pod-role"; do
    if check_and_delete "IAM role" "$role" "aws iam get-role --role-name $role --region $AWS_REGION"; then
        echo "🗑️ Deleting IAM role: $role"
        # Detach policies first
        aws iam list-attached-role-policies --role-name $role --query 'AttachedPolicies[*].PolicyArn' --output text | while read -r policy_arn; do
            if [ -n "$policy_arn" ]; then
                echo "  📋 Detaching policy: $policy_arn"
                aws iam detach-role-policy --role-name $role --policy-arn "$policy_arn" || echo "  ⚠️ Could not detach policy"
            fi
        done
        # Delete role
        aws iam delete-role --role-name $role --region $AWS_REGION || echo "⚠️ Role may have already been deleted"
        echo "✅ IAM role deleted: $role"
    fi
done

# Clean up Secrets Manager secrets
for secret in "thrive-cluster-test-github-actions-credentials" "thrive-cluster-test-app-secrets"; do
    if check_and_delete "Secret" "$secret" "aws secretsmanager describe-secret --secret-id $secret --region $AWS_REGION"; then
        echo "🗑️ Deleting secret: $secret"
        aws secretsmanager delete-secret --secret-id $secret --region $AWS_REGION --force-delete-without-recovery || echo "⚠️ Secret may have already been deleted"
        echo "✅ Secret deleted: $secret"
    fi
done

# Clean up CloudWatch log groups
if check_and_delete "CloudWatch log group" "/aws/eks/$CLUSTER_NAME/cluster" "aws logs describe-log-groups --log-group-name-prefix \"/aws/eks/$CLUSTER_NAME\" --region $AWS_REGION --query 'logGroups[0].logGroupName' --output text | grep -q \"$CLUSTER_NAME\""; then
    echo "🗑️ Deleting CloudWatch log group..."
    aws logs delete-log-group --log-group-name "/aws/eks/$CLUSTER_NAME/cluster" --region $AWS_REGION || echo "⚠️ Log group may have already been deleted"
    echo "✅ CloudWatch log group deleted"
fi

# Clean up OIDC providers
OIDC_PROVIDERS=$(aws iam list-open-id-connect-providers --region $AWS_REGION --query 'OpenIDConnectProviderList[?contains(Arn, `thrive-cluster-test`)].Arn' --output text 2>/dev/null || echo "")
if [ -n "$OIDC_PROVIDERS" ]; then
    for provider in $OIDC_PROVIDERS; do
        echo "🗑️ Deleting OIDC provider: $provider"
        aws iam delete-open-id-connect-provider --open-id-connect-provider-arn "$provider" --region $AWS_REGION || echo "⚠️ OIDC provider may have already been deleted"
    done
    echo "✅ OIDC providers deleted"
fi

# Clean up VPC resources
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Project,Values=Thrive_Cluster_Test" --query 'Vpcs[0].VpcId' --output text --region $AWS_REGION 2>/dev/null || echo "None")
if [ "$VPC_ID" != "None" ] && [ "$VPC_ID" != "null" ]; then
    echo "🗑️ Deleting VPC and related resources..."
    # Delete subnets
    SUBNETS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[*].SubnetId' --output text --region $AWS_REGION 2>/dev/null || echo "")
    if [ -n "$SUBNETS" ]; then
        for subnet in $SUBNETS; do
            echo "  🗑️ Deleting subnet: $subnet"
            aws ec2 delete-subnet --subnet-id $subnet --region $AWS_REGION || echo "  ⚠️ Subnet may have already been deleted"
        done
    fi
    # Delete internet gateway
    IGW_ID=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query 'InternetGateways[0].InternetGatewayId' --output text --region $AWS_REGION 2>/dev/null || echo "None")
    if [ "$IGW_ID" != "None" ] && [ "$IGW_ID" != "null" ]; then
        echo "  🗑️ Detaching and deleting internet gateway: $IGW_ID"
        aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID --region $AWS_REGION || echo "  ⚠️ Could not detach IGW"
        aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID --region $AWS_REGION || echo "  ⚠️ Could not delete IGW"
    fi
    # Delete VPC
    aws ec2 delete-vpc --vpc-id $VPC_ID --region $AWS_REGION || echo "⚠️ VPC may have already been deleted"
    echo "✅ VPC and related resources deleted"
fi

echo ""
echo "🎯 Cleanup Summary"
echo "=================="
echo "✅ Partial deployment cleanup completed"
echo "💡 You can now retry the deployment"
echo "🚀 Run: terraform apply or trigger GitHub Actions workflow"
echo ""
echo "📊 To verify cleanup, run: ./scripts/verify-aws-cleanup.sh"

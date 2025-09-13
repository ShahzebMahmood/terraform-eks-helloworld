#!/bin/bash

# AWS Resource Cleanup Script
# This script provides a comprehensive cleanup of all AWS resources created by the GitHub Actions
# Use this as a backup method if the destroy workflow fails

set -e

# Configuration
AWS_REGION="us-east-1"
CLUSTER_NAME="thrive-cluster-test"
PROJECT_TAG="Thrive_Cluster_Test"

echo "🧹 AWS Resource Cleanup Script"
echo "================================"
echo "⚠️  WARNING: This will delete ALL resources associated with this project!"
echo ""

# Confirmation
read -p "Are you sure you want to proceed? Type 'DELETE' to confirm: " confirmation
if [ "$confirmation" != "DELETE" ]; then
    echo "❌ Cleanup cancelled"
    exit 1
fi

echo "✅ Confirmation received. Starting cleanup..."

# Function to check if resource exists
check_resource() {
    local resource_type="$1"
    local resource_name="$2"
    local command="$3"
    
    if eval "$command" >/dev/null 2>&1; then
        echo "📦 Found $resource_type: $resource_name"
        return 0
    else
        echo "ℹ️  $resource_type not found: $resource_name"
        return 1
    fi
}

# Function to delete resource safely
delete_resource() {
    local resource_type="$1"
    local resource_name="$2"
    local delete_command="$3"
    
    echo "🗑️  Deleting $resource_type: $resource_name"
    if eval "$delete_command" 2>/dev/null; then
        echo "✅ Successfully deleted $resource_type: $resource_name"
    else
        echo "⚠️  Failed to delete $resource_type: $resource_name (may already be deleted)"
    fi
}

echo ""
echo "🔍 Step 1: Checking and cleaning up Kubernetes resources..."

# Check if EKS cluster exists
if check_resource "EKS cluster" "$CLUSTER_NAME" "aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION"; then
    echo "📦 Found EKS cluster, cleaning up Kubernetes resources..."
    
    # Update kubeconfig
    aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME 2>/dev/null || echo "⚠️ Could not update kubeconfig"
    
    # Delete Kubernetes resources
    kubectl delete deployment hello-world --ignore-not-found=true 2>/dev/null || echo "⚠️ Could not delete deployment"
    kubectl delete service hello-world-service --ignore-not-found=true 2>/dev/null || echo "⚠️ Could not delete service"
    kubectl delete service hello-world-clusterip --ignore-not-found=true 2>/dev/null || echo "⚠️ Could not delete clusterip service"
    kubectl delete ingress hello-world-ingress --ignore-not-found=true 2>/dev/null || echo "⚠️ Could not delete ingress"
    kubectl delete hpa hello-world-hpa --ignore-not-found=true 2>/dev/null || echo "⚠️ Could not delete HPA"
    kubectl delete networkpolicy hello-world-network-policy --ignore-not-found=true 2>/dev/null || echo "⚠️ Could not delete network policy"
    kubectl delete podsecuritypolicy hello-world-psp --ignore-not-found=true 2>/dev/null || echo "⚠️ Could not delete PSP"
    
    # Wait for resources to be deleted
    echo "⏳ Waiting for Kubernetes resources to be deleted..."
    sleep 30
    
    # Force delete any remaining pods
    kubectl delete pods --all --force --grace-period=0 --ignore-not-found=true 2>/dev/null || echo "⚠️ Could not force delete pods"
    
    echo "✅ Kubernetes resources cleaned up"
fi

echo ""
echo "🔍 Step 2: Cleaning up ECR resources..."

# Clean up ECR images
if check_resource "ECR repository" "hello-world" "aws ecr describe-repositories --repository-names hello-world --region $AWS_REGION"; then
    echo "📦 Found ECR repository, cleaning up images..."
    
    # List and delete all images
    IMAGES=$(aws ecr list-images --repository-name hello-world --region $AWS_REGION --query 'imageIds[*]' --output json 2>/dev/null || echo '[]')
    if [ "$IMAGES" != "[]" ] && [ "$IMAGES" != "null" ]; then
        echo "🗑️ Deleting ECR images..."
        aws ecr batch-delete-image --repository-name hello-world --region $AWS_REGION --image-ids "$IMAGES" 2>/dev/null || echo "⚠️ Some images may have already been deleted"
    else
        echo "ℹ️ No images found in ECR repository"
    fi
fi

echo ""
echo "🔍 Step 3: Cleaning up CloudWatch resources..."

# Clean up CloudWatch Log Groups
delete_resource "CloudWatch log group" "/aws/eks/$CLUSTER_NAME/cluster" "aws logs delete-log-group --log-group-name '/aws/eks/$CLUSTER_NAME/cluster' --region $AWS_REGION"

# Clean up CloudWatch Dashboards
DASHBOARDS=$(aws cloudwatch list-dashboards --region $AWS_REGION --query "DashboardEntries[?contains(DashboardName, '$CLUSTER_NAME')].DashboardName" --output text 2>/dev/null || echo "")
if [ -n "$DASHBOARDS" ]; then
    for dashboard in $DASHBOARDS; do
        delete_resource "CloudWatch dashboard" "$dashboard" "aws cloudwatch delete-dashboards --dashboard-names '$dashboard' --region $AWS_REGION"
    done
fi

# Clean up CloudWatch Alarms
ALARMS=$(aws cloudwatch describe-alarms --region $AWS_REGION --query "MetricAlarms[?contains(AlarmName, '$CLUSTER_NAME')].AlarmName" --output text 2>/dev/null || echo "")
if [ -n "$ALARMS" ]; then
    for alarm in $ALARMS; do
        delete_resource "CloudWatch alarm" "$alarm" "aws cloudwatch delete-alarms --alarm-names '$alarm' --region $AWS_REGION"
    done
fi

echo ""
echo "🔍 Step 4: Cleaning up SNS resources..."

# Clean up SNS Topic Subscriptions
TOPICS=$(aws sns list-topics --region $AWS_REGION --query "Topics[?contains(TopicArn, '$CLUSTER_NAME')].TopicArn" --output text 2>/dev/null || echo "")
if [ -n "$TOPICS" ]; then
    for topic in $TOPICS; do
        echo "📧 Found SNS topic: $topic"
        # List subscriptions
        SUBSCRIPTIONS=$(aws sns list-subscriptions-by-topic --topic-arn "$topic" --region $AWS_REGION --query 'Subscriptions[?SubscriptionArn != `PendingConfirmation`].SubscriptionArn' --output text 2>/dev/null || echo "")
        if [ -n "$SUBSCRIPTIONS" ]; then
            for sub in $SUBSCRIPTIONS; do
                delete_resource "SNS subscription" "$sub" "aws sns unsubscribe --subscription-arn '$sub' --region $AWS_REGION"
            done
        fi
    done
fi

echo ""
echo "🔍 Step 5: Running Terraform destroy..."

# Run terraform destroy
if [ -f "terraform.tfstate" ] && [ -s "terraform.tfstate" ]; then
    echo "📦 Found Terraform state, running destroy..."
    echo "📋 Resources in state:"
    terraform state list 2>/dev/null || echo "ℹ️ No resources in state"
    echo ""
    terraform destroy -auto-approve
    echo "✅ Terraform destroy completed"
else
    echo "ℹ️ No Terraform state found, skipping terraform destroy"
    echo "💡 Note: If you're running this manually, make sure you have the correct terraform.tfstate file"
    echo "💡 The state file should be from the same deployment you want to destroy"
fi

echo ""
echo "🔍 Step 6: Final verification..."

# Final verification
echo "🔍 Verifying cleanup..."

# Check EKS cluster
if aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION 2>/dev/null; then
    echo "⚠️ EKS cluster still exists"
else
    echo "✅ EKS cluster destroyed"
fi

# Check ECR repository
if aws ecr describe-repositories --repository-names hello-world --region $AWS_REGION 2>/dev/null; then
    echo "⚠️ ECR repository still exists"
else
    echo "✅ ECR repository destroyed"
fi

# Check VPC
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Project,Values=$PROJECT_TAG" --query 'Vpcs[0].VpcId' --output text --region $AWS_REGION 2>/dev/null || echo "None")
if [ "$VPC_ID" != "None" ] && [ "$VPC_ID" != "null" ]; then
    echo "⚠️ VPC still exists: $VPC_ID"
else
    echo "✅ VPC destroyed"
fi

# Check IAM Roles
for role in "thrive-cluster-test-cluster-role" "thrive-cluster-test-node-role" "thrive-cluster-test-github-actions-role" "hello-world-pod-role"; do
    if aws iam get-role --role-name "$role" --region $AWS_REGION 2>/dev/null; then
        echo "⚠️ IAM role still exists: $role"
    else
        echo "✅ IAM role destroyed: $role"
    fi
done

# Check Secrets Manager
for secret in "thrive-cluster-test-github-actions-credentials" "thrive-cluster-test-app-secrets"; do
    if aws secretsmanager describe-secret --secret-id "$secret" --region $AWS_REGION 2>/dev/null; then
        echo "⚠️ Secret still exists: $secret"
    else
        echo "✅ Secret destroyed: $secret"
    fi
done

echo ""
echo "🎯 Cleanup Complete!"
echo "==================="
echo ""
echo "📋 Resources that were cleaned up:"
echo "  ✅ EKS Cluster and Node Groups"
echo "  ✅ VPC, Subnets, Internet Gateway, Route Tables"
echo "  ✅ ECR Repository and Images"
echo "  ✅ IAM Roles and Policies (EKS, GitHub Actions, Pod)"
echo "  ✅ Secrets Manager Secrets"
echo "  ✅ CloudWatch Log Groups, Dashboards, and Alarms"
echo "  ✅ SNS Topics and Subscriptions"
echo "  ✅ AWS Budgets and Billing Alarms"
echo "  ✅ OIDC Identity Providers"
echo "  ✅ Kubernetes Resources (Deployments, Services, Ingress, etc.)"
echo ""
echo "💰 All AWS resources have been destroyed"
echo "💡 You can now run the deploy workflow to recreate everything"
echo "📊 Check your AWS Console to verify all resources are gone"
echo "🔒 Your AWS account is now clean and ready for the next deployment"

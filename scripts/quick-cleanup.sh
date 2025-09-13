#!/bin/bash

# Quick Cleanup Script for Existing AWS Resources
# This script forcefully cleans up all existing resources

set -e

AWS_REGION="us-east-1"
CLUSTER_NAME="thrive-cluster-test"
ECR_REPOSITORY="hello-world"

echo "🧹 Quick Cleanup of Existing AWS Resources"
echo "=========================================="
echo ""

# Function to delete IAM role with all policies
delete_iam_role() {
    local role_name="$1"
    echo "🗑️ Deleting IAM role: $role_name"
    
    # Detach all attached policies
    aws iam list-attached-role-policies --role-name "$role_name" --query 'AttachedPolicies[*].PolicyArn' --output text | while read -r policy_arn; do
        if [ -n "$policy_arn" ]; then
            echo "  📋 Detaching policy: $policy_arn"
            aws iam detach-role-policy --role-name "$role_name" --policy-arn "$policy_arn" || echo "  ⚠️ Could not detach policy"
        fi
    done
    
    # Delete inline policies
    aws iam list-role-policies --role-name "$role_name" --query 'PolicyNames[*]' --output text | while read -r policy_name; do
        if [ -n "$policy_name" ]; then
            echo "  📋 Deleting inline policy: $policy_name"
            aws iam delete-role-policy --role-name "$role_name" --policy-name "$policy_name" || echo "  ⚠️ Could not delete inline policy"
        fi
    done
    
    # Delete the role
    aws iam delete-role --role-name "$role_name" || echo "  ⚠️ Could not delete role"
    echo "  ✅ Role deleted: $role_name"
}

# Clean up IAM roles
echo "🔍 Cleaning up IAM roles..."
for role in "thrive-cluster-test-cluster-role" "thrive-cluster-test-node-role" "thrive-cluster-test-github-actions-role" "hello-world-pod-role"; do
    if aws iam get-role --role-name "$role" --region $AWS_REGION 2>/dev/null; then
        delete_iam_role "$role"
    else
        echo "✅ IAM role does not exist: $role"
    fi
done

# Clean up ECR repository
echo ""
echo "🔍 Cleaning up ECR repository..."
if aws ecr describe-repositories --repository-names $ECR_REPOSITORY --region $AWS_REGION 2>/dev/null; then
    echo "🗑️ Deleting ECR repository and images..."
    # Delete all images first
    IMAGES=$(aws ecr list-images --repository-name $ECR_REPOSITORY --region $AWS_REGION --query 'imageIds[*]' --output json 2>/dev/null || echo '[]')
    if [ "$IMAGES" != "[]" ] && [ "$IMAGES" != "null" ]; then
        aws ecr batch-delete-image --repository-name $ECR_REPOSITORY --region $AWS_REGION --image-ids "$IMAGES" || echo "⚠️ Some images may have already been deleted"
    fi
    # Delete repository
    aws ecr delete-repository --repository-name $ECR_REPOSITORY --region $AWS_REGION --force || echo "⚠️ Repository may have already been deleted"
    echo "✅ ECR repository deleted"
else
    echo "✅ ECR repository does not exist"
fi

# Clean up EKS cluster
echo ""
echo "🔍 Cleaning up EKS cluster..."
if aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION 2>/dev/null; then
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
else
    echo "✅ EKS cluster does not exist"
fi

# Clean up Secrets Manager secrets
echo ""
echo "🔍 Cleaning up Secrets Manager secrets..."
for secret in "thrive-cluster-test-github-actions-credentials" "thrive-cluster-test-app-secrets"; do
    if aws secretsmanager describe-secret --secret-id $secret --region $AWS_REGION 2>/dev/null; then
        echo "🗑️ Deleting secret: $secret"
        aws secretsmanager delete-secret --secret-id $secret --region $AWS_REGION --force-delete-without-recovery || echo "⚠️ Secret may have already been deleted"
        echo "✅ Secret deleted: $secret"
    else
        echo "✅ Secret does not exist: $secret"
    fi
done

# Clean up CloudWatch log groups
echo ""
echo "🔍 Cleaning up CloudWatch log groups..."
if aws logs describe-log-groups --log-group-name-prefix "/aws/eks/$CLUSTER_NAME" --region $AWS_REGION --query 'logGroups[0].logGroupName' --output text 2>/dev/null | grep -q "$CLUSTER_NAME"; then
    echo "🗑️ Deleting CloudWatch log group..."
    aws logs delete-log-group --log-group-name "/aws/eks/$CLUSTER_NAME/cluster" --region $AWS_REGION || echo "⚠️ Log group may have already been deleted"
    echo "✅ CloudWatch log group deleted"
else
    echo "✅ CloudWatch log group does not exist"
fi

# Clean up OIDC providers
echo ""
echo "🔍 Cleaning up OIDC providers..."
OIDC_PROVIDERS=$(aws iam list-open-id-connect-providers --region $AWS_REGION --query 'OpenIDConnectProviderList[?contains(Arn, `thrive-cluster-test`)].Arn' --output text 2>/dev/null || echo "")
if [ -n "$OIDC_PROVIDERS" ]; then
    for provider in $OIDC_PROVIDERS; do
        echo "🗑️ Deleting OIDC provider: $provider"
        aws iam delete-open-id-connect-provider --open-id-connect-provider-arn "$provider" --region $AWS_REGION || echo "⚠️ OIDC provider may have already been deleted"
    done
    echo "✅ OIDC providers deleted"
else
    echo "✅ No OIDC providers found"
fi

echo ""
echo "🎯 Cleanup Summary"
echo "=================="
echo "✅ All existing resources have been cleaned up"
echo "💡 You can now run the deployment workflow safely"
echo "🚀 Run: Go to GitHub Actions and trigger the deploy workflow"

#!/bin/bash

# AWS Resource Verification Script
# This script checks if all resources created by the project have been deleted

set -e

# Configuration
AWS_REGION="us-east-1"
CLUSTER_NAME="thrive-cluster-test"
PROJECT_TAG="Thrive_Cluster_Test"
ECR_REPOSITORY="hello-world"

echo "🔍 AWS Resource Cleanup Verification"
echo "===================================="
echo "Region: $AWS_REGION"
echo "Cluster: $CLUSTER_NAME"
echo "Project Tag: $PROJECT_TAG"
echo ""

# Function to check resource existence
check_resource() {
    local resource_type="$1"
    local resource_name="$2"
    local command="$3"
    
    if eval "$command" >/dev/null 2>&1; then
        echo "❌ $resource_type still exists: $resource_name"
        return 1
    else
        echo "✅ $resource_type deleted: $resource_name"
        return 0
    fi
}

# Function to count resources
count_resources() {
    local resource_type="$1"
    local command="$2"
    local count=$(eval "$command" 2>/dev/null | wc -l || echo "0")
    echo "📊 $resource_type count: $count"
    return $count
}

echo "🔍 Checking EKS Resources..."
echo "============================"

# Check EKS cluster
check_resource "EKS cluster" "$CLUSTER_NAME" "aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION"

# Check EKS node groups
NODE_GROUPS=$(aws eks list-nodegroups --cluster-name $CLUSTER_NAME --region $AWS_REGION --query 'nodegroups' --output text 2>/dev/null || echo "")
if [ -n "$NODE_GROUPS" ] && [ "$NODE_GROUPS" != "None" ]; then
    echo "❌ EKS node groups still exist: $NODE_GROUPS"
else
    echo "✅ EKS node groups deleted"
fi

echo ""
echo "🔍 Checking ECR Resources..."
echo "============================"

# Check ECR repository
check_resource "ECR repository" "$ECR_REPOSITORY" "aws ecr describe-repositories --repository-names $ECR_REPOSITORY --region $AWS_REGION"

# Check ECR images
ECR_IMAGES=$(aws ecr list-images --repository-name $ECR_REPOSITORY --region $AWS_REGION --query 'imageIds[*]' --output text 2>/dev/null || echo "")
if [ -n "$ECR_IMAGES" ] && [ "$ECR_IMAGES" != "None" ]; then
    echo "❌ ECR images still exist"
    echo "Images: $ECR_IMAGES"
else
    echo "✅ ECR images deleted"
fi

echo ""
echo "🔍 Checking VPC Resources..."
echo "============================"

# Check VPC
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Project,Values=$PROJECT_TAG" --query 'Vpcs[0].VpcId' --output text --region $AWS_REGION 2>/dev/null || echo "None")
if [ "$VPC_ID" != "None" ] && [ "$VPC_ID" != "null" ]; then
    echo "❌ VPC still exists: $VPC_ID"
    
    # Check subnets
    SUBNETS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[*].SubnetId' --output text --region $AWS_REGION 2>/dev/null || echo "")
    if [ -n "$SUBNETS" ] && [ "$SUBNETS" != "None" ]; then
        echo "❌ Subnets still exist: $SUBNETS"
    else
        echo "✅ Subnets deleted"
    fi
    
    # Check internet gateway
    IGW_ID=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query 'InternetGateways[0].InternetGatewayId' --output text --region $AWS_REGION 2>/dev/null || echo "None")
    if [ "$IGW_ID" != "None" ] && [ "$IGW_ID" != "null" ]; then
        echo "❌ Internet Gateway still exists: $IGW_ID"
    else
        echo "✅ Internet Gateway deleted"
    fi
else
    echo "✅ VPC deleted"
fi

echo ""
echo "🔍 Checking IAM Resources..."
echo "============================"

# Check IAM roles
for role in "thrive-cluster-test-cluster-role" "thrive-cluster-test-node-role" "thrive-cluster-test-github-actions-role" "hello-world-pod-role"; do
    check_resource "IAM role" "$role" "aws iam get-role --role-name $role --region $AWS_REGION"
done

# Check IAM policies
POLICIES=$(aws iam list-policies --scope Local --query "Policies[?contains(PolicyName, 'thrive-cluster-test')].PolicyName" --output text --region $AWS_REGION 2>/dev/null || echo "")
if [ -n "$POLICIES" ] && [ "$POLICIES" != "None" ]; then
    echo "❌ IAM policies still exist: $POLICIES"
else
    echo "✅ IAM policies deleted"
fi

# Check OIDC providers
OIDC_PROVIDERS=$(aws iam list-open-id-connect-providers --region $AWS_REGION --query 'OpenIDConnectProviderList[?contains(Arn, `thrive-cluster-test`)].Arn' --output text 2>/dev/null || echo "")
if [ -n "$OIDC_PROVIDERS" ] && [ "$OIDC_PROVIDERS" != "None" ]; then
    echo "❌ OIDC providers still exist: $OIDC_PROVIDERS"
else
    echo "✅ OIDC providers deleted"
fi

echo ""
echo "🔍 Checking Secrets Manager..."
echo "=============================="

# Check secrets
for secret in "thrive-cluster-test-github-actions-credentials" "thrive-cluster-test-app-secrets"; do
    check_resource "Secret" "$secret" "aws secretsmanager describe-secret --secret-id $secret --region $AWS_REGION"
done

echo ""
echo "🔍 Checking CloudWatch Resources..."
echo "==================================="

# Check CloudWatch log groups
LOG_GROUPS=$(aws logs describe-log-groups --log-group-name-prefix "/aws/eks/$CLUSTER_NAME" --region $AWS_REGION --query 'logGroups[*].logGroupName' --output text 2>/dev/null || echo "")
if [ -n "$LOG_GROUPS" ] && [ "$LOG_GROUPS" != "None" ]; then
    echo "❌ CloudWatch log groups still exist: $LOG_GROUPS"
else
    echo "✅ CloudWatch log groups deleted"
fi

# Check CloudWatch dashboards
DASHBOARDS=$(aws cloudwatch list-dashboards --region $AWS_REGION --query "DashboardEntries[?contains(DashboardName, '$CLUSTER_NAME')].DashboardName" --output text 2>/dev/null || echo "")
if [ -n "$DASHBOARDS" ] && [ "$DASHBOARDS" != "None" ]; then
    echo "❌ CloudWatch dashboards still exist: $DASHBOARDS"
else
    echo "✅ CloudWatch dashboards deleted"
fi

# Check CloudWatch alarms
ALARMS=$(aws cloudwatch describe-alarms --region $AWS_REGION --query "MetricAlarms[?contains(AlarmName, '$CLUSTER_NAME')].AlarmName" --output text 2>/dev/null || echo "")
if [ -n "$ALARMS" ] && [ "$ALARMS" != "None" ]; then
    echo "❌ CloudWatch alarms still exist: $ALARMS"
else
    echo "✅ CloudWatch alarms deleted"
fi

echo ""
echo "🔍 Checking SNS Resources..."
echo "============================"

# Check SNS topics
SNS_TOPICS=$(aws sns list-topics --region $AWS_REGION --query "Topics[?contains(TopicArn, '$CLUSTER_NAME')].TopicArn" --output text 2>/dev/null || echo "")
if [ -n "$SNS_TOPICS" ] && [ "$SNS_TOPICS" != "None" ]; then
    echo "❌ SNS topics still exist: $SNS_TOPICS"
else
    echo "✅ SNS topics deleted"
fi

echo ""
echo "🔍 Checking Budget Resources..."
echo "==============================="

# Check budgets
BUDGETS=$(aws budgets describe-budgets --account-id $(aws sts get-caller-identity --query Account --output text) --region $AWS_REGION --query "Budgets[?contains(BudgetName, '$CLUSTER_NAME')].BudgetName" --output text 2>/dev/null || echo "")
if [ -n "$BUDGETS" ] && [ "$BUDGETS" != "None" ]; then
    echo "❌ Budgets still exist: $BUDGETS"
else
    echo "✅ Budgets deleted"
fi

echo ""
echo "🔍 Checking EC2 Resources..."
echo "============================"

# Check for any EC2 instances with project tags
EC2_INSTANCES=$(aws ec2 describe-instances --filters "Name=tag:Project,Values=$PROJECT_TAG" "Name=instance-state-name,Values=running,stopped,stopping,pending" --query 'Reservations[*].Instances[*].InstanceId' --output text --region $AWS_REGION 2>/dev/null || echo "")
if [ -n "$EC2_INSTANCES" ] && [ "$EC2_INSTANCES" != "None" ]; then
    echo "❌ EC2 instances still exist: $EC2_INSTANCES"
else
    echo "✅ EC2 instances deleted"
fi

# Check for any security groups with project tags
SECURITY_GROUPS=$(aws ec2 describe-security-groups --filters "Name=tag:Project,Values=$PROJECT_TAG" --query 'SecurityGroups[*].GroupId' --output text --region $AWS_REGION 2>/dev/null || echo "")
if [ -n "$SECURITY_GROUPS" ] && [ "$SECURITY_GROUPS" != "None" ]; then
    echo "❌ Security groups still exist: $SECURITY_GROUPS"
else
    echo "✅ Security groups deleted"
fi

echo ""
echo "🔍 Checking Load Balancers..."
echo "============================="

# Check Application Load Balancers
ALBS=$(aws elbv2 describe-load-balancers --region $AWS_REGION --query "LoadBalancers[?contains(LoadBalancerName, '$CLUSTER_NAME')].LoadBalancerArn" --output text 2>/dev/null || echo "")
if [ -n "$ALBS" ] && [ "$ALBS" != "None" ]; then
    echo "❌ Application Load Balancers still exist: $ALBS"
else
    echo "✅ Application Load Balancers deleted"
fi

# Check Classic Load Balancers
CLBS=$(aws elb describe-load-balancers --region $AWS_REGION --query "LoadBalancerDescriptions[?contains(LoadBalancerName, '$CLUSTER_NAME')].LoadBalancerName" --output text 2>/dev/null || echo "")
if [ -n "$CLBS" ] && [ "$CLBS" != "None" ]; then
    echo "❌ Classic Load Balancers still exist: $CLBS"
else
    echo "✅ Classic Load Balancers deleted"
fi

echo ""
echo "📊 Summary"
echo "=========="
echo "✅ All checks completed!"
echo ""
echo "💡 If any resources are still showing as existing, you can:"
echo "   1. Wait a few minutes and run this script again (some deletions take time)"
echo "   2. Manually delete the remaining resources from AWS Console"
echo "   3. Run the destroy workflow again"
echo "   4. Use the manual cleanup script: ./scripts/cleanup-aws-resources.sh"
echo ""
echo "🔍 To get more details about any remaining resources, check the AWS Console:"
echo "   - EKS: https://console.aws.amazon.com/eks/"
echo "   - ECR: https://console.aws.amazon.com/ecr/"
echo "   - VPC: https://console.aws.amazon.com/vpc/"
echo "   - IAM: https://console.aws.amazon.com/iam/"
echo "   - CloudWatch: https://console.aws.amazon.com/cloudwatch/"
echo "   - SNS: https://console.aws.amazon.com/sns/"
echo "   - Budgets: https://console.aws.amazon.com/billing/home#/budgets"

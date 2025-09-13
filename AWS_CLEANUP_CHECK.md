# 🔍 AWS Cleanup Verification Guide

This guide shows you how to verify that all AWS resources have been deleted after running the destroy workflow.

## 🚀 Quick Verification Script

Run the comprehensive verification script:

```bash
./scripts/verify-aws-cleanup.sh
```

This script checks all resource types and gives you a complete report.

## 🔧 Manual AWS CLI Commands

If you prefer to check manually, here are the key commands:

### EKS Resources
```bash
# Check EKS cluster
aws eks describe-cluster --name thrive-cluster-test --region us-east-1

# Check EKS node groups
aws eks list-nodegroups --cluster-name thrive-cluster-test --region us-east-1
```

### ECR Resources
```bash
# Check ECR repository
aws ecr describe-repositories --repository-names hello-world --region us-east-1

# Check ECR images
aws ecr list-images --repository-name hello-world --region us-east-1
```

### VPC Resources
```bash
# Check VPC
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=Thrive_Cluster_Test" --region us-east-1

# Check subnets
aws ec2 describe-subnets --filters "Name=tag:Project,Values=Thrive_Cluster_Test" --region us-east-1

# Check internet gateways
aws ec2 describe-internet-gateways --filters "Name=tag:Project,Values=Thrive_Cluster_Test" --region us-east-1
```

### IAM Resources
```bash
# Check IAM roles
aws iam get-role --role-name thrive-cluster-test-cluster-role
aws iam get-role --role-name thrive-cluster-test-node-role
aws iam get-role --role-name thrive-cluster-test-github-actions-role
aws iam get-role --role-name hello-world-pod-role

# Check IAM policies
aws iam list-policies --scope Local --query "Policies[?contains(PolicyName, 'thrive-cluster-test')]"

# Check OIDC providers
aws iam list-open-id-connect-providers --query 'OpenIDConnectProviderList[?contains(Arn, `thrive-cluster-test`)]'
```

### Secrets Manager
```bash
# Check secrets
aws secretsmanager describe-secret --secret-id thrive-cluster-test-github-actions-credentials --region us-east-1
aws secretsmanager describe-secret --secret-id thrive-cluster-test-app-secrets --region us-east-1
```

### CloudWatch Resources
```bash
# Check log groups
aws logs describe-log-groups --log-group-name-prefix "/aws/eks/thrive-cluster-test" --region us-east-1

# Check dashboards
aws cloudwatch list-dashboards --region us-east-1 --query "DashboardEntries[?contains(DashboardName, 'thrive-cluster-test')]"

# Check alarms
aws cloudwatch describe-alarms --region us-east-1 --query "MetricAlarms[?contains(AlarmName, 'thrive-cluster-test')]"
```

### SNS Resources
```bash
# Check SNS topics
aws sns list-topics --region us-east-1 --query "Topics[?contains(TopicArn, 'thrive-cluster-test')]"
```

### Budget Resources
```bash
# Check budgets
aws budgets describe-budgets --account-id $(aws sts get-caller-identity --query Account --output text) --region us-east-1 --query "Budgets[?contains(BudgetName, 'thrive-cluster-test')]"
```

### EC2 Resources
```bash
# Check EC2 instances
aws ec2 describe-instances --filters "Name=tag:Project,Values=Thrive_Cluster_Test" --region us-east-1

# Check security groups
aws ec2 describe-security-groups --filters "Name=tag:Project,Values=Thrive_Cluster_Test" --region us-east-1
```

### Load Balancers
```bash
# Check Application Load Balancers
aws elbv2 describe-load-balancers --region us-east-1 --query "LoadBalancers[?contains(LoadBalancerName, 'thrive-cluster-test')]"

# Check Classic Load Balancers
aws elb describe-load-balancers --region us-east-1 --query "LoadBalancerDescriptions[?contains(LoadBalancerName, 'thrive-cluster-test')]"
```

## 🌐 AWS Console Links

You can also check visually in the AWS Console:

- **EKS**: https://console.aws.amazon.com/eks/
- **ECR**: https://console.aws.amazon.com/ecr/
- **VPC**: https://console.aws.amazon.com/vpc/
- **IAM**: https://console.aws.amazon.com/iam/
- **Secrets Manager**: https://console.aws.amazon.com/secretsmanager/
- **CloudWatch**: https://console.aws.amazon.com/cloudwatch/
- **SNS**: https://console.aws.amazon.com/sns/
- **Budgets**: https://console.aws.amazon.com/billing/home#/budgets
- **EC2**: https://console.aws.amazon.com/ec2/
- **Load Balancers**: https://console.aws.amazon.com/ec2/v2/home#LoadBalancers:

## 📊 Expected Results

When everything is properly deleted, you should see:

- ✅ **EKS cluster**: "An error occurred (ResourceNotFoundException)"
- ✅ **ECR repository**: "An error occurred (RepositoryNotFoundException)"
- ✅ **VPC**: Empty list or no VPCs with project tag
- ✅ **IAM roles**: "An error occurred (NoSuchEntity)"
- ✅ **Secrets**: "An error occurred (ResourceNotFoundException)"
- ✅ **CloudWatch**: Empty lists for log groups, dashboards, alarms
- ✅ **SNS**: Empty list for topics
- ✅ **Budgets**: Empty list for budgets
- ✅ **EC2**: Empty lists for instances and security groups
- ✅ **Load Balancers**: Empty lists for ALBs and CLBs

## 🚨 If Resources Still Exist

If you find resources that weren't deleted:

1. **Wait a few minutes** - Some deletions take time
2. **Run the destroy workflow again**
3. **Use the manual cleanup script**: `./scripts/cleanup-aws-resources.sh`
4. **Manually delete from AWS Console**
5. **Check for dependencies** - Some resources can't be deleted if others depend on them

## 💡 Pro Tips

- **Run the verification script** after every destroy to ensure complete cleanup
- **Check AWS Billing** to confirm no unexpected charges
- **Use AWS Cost Explorer** to monitor costs over time
- **Set up billing alerts** to get notified of unexpected charges

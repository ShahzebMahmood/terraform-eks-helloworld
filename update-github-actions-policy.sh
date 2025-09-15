#!/bin/bash

# Script to update GitHub Actions IAM policy with missing destroy permissions
# Run this if you encounter permission errors during terraform destroy

echo "🔧 Updating GitHub Actions IAM policy for terraform destroy..."

POLICY_NAME="thrive-cluster-test-github-actions-policy"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Check if policy exists
if ! aws iam get-policy --policy-arn "arn:aws:iam::$ACCOUNT_ID:policy/$POLICY_NAME" >/dev/null 2>&1; then
  echo "❌ Policy $POLICY_NAME not found. Please run setup-backend workflow first."
  exit 1
fi

echo "📝 Creating updated policy document..."

# Create updated policy with all required permissions
cat > updated-github-actions-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:DescribeRepositories",
        "ecr:CreateRepository",
        "ecr:DeleteRepository",
        "eks:DescribeCluster",
        "eks:ListClusters",
        "eks:UpdateClusterConfig",
        "eks:CreateCluster",
        "eks:DeleteCluster",
        "eks:TagResource",
        "eks:UntagResource",
        "eks:ListTagsForResource",
        "eks:CreateNodegroup",
        "eks:DeleteNodegroup",
        "eks:DescribeNodegroup",
        "eks:ListNodegroups",
        "eks:UpdateNodegroupConfig",
        "eks:UpdateNodegroupVersion",
        "eks:CreateAddon",
        "eks:DeleteAddon",
        "eks:DescribeAddon",
        "eks:ListAddons",
        "eks:UpdateAddon",
        "eks:DescribeAddonVersions",
        "eks:CreatePodIdentityAssociation",
        "eks:DeletePodIdentityAssociation",
        "eks:DescribePodIdentityAssociation",
        "eks:ListPodIdentityAssociations",
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:GetRole",
        "iam:PassRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:ListAttachedRolePolicies",
        "iam:ListRolePolicies",
        "iam:CreatePolicy",
        "iam:DeletePolicy",
        "iam:GetPolicy",
        "iam:GetPolicyVersion",
        "iam:ListPolicyVersions",
        "iam:ListPolicies",
        "iam:CreatePolicyVersion",
        "iam:DeletePolicyVersion",
        "iam:TagRole",
        "iam:UntagRole",
        "iam:ListRoleTags",
        "iam:TagPolicy",
        "iam:UntagPolicy",
        "iam:ListPolicyTags",
        "iam:ListOpenIDConnectProviders",
        "iam:GetOpenIDConnectProvider",
        "s3:*",
        "dynamodb:*",
        "secretsmanager:*",
        "sns:*",
        "budgets:*",
        "kms:*",
        "ec2:*",
        "vpc:*",
        "cloudwatch:*",
        "logs:*",
        "acm:*",
        "route53:*",
        "sts:GetCallerIdentity"
      ],
      "Resource": "*"
    }
  ]
}
EOF

echo "🚀 Updating IAM policy..."

# Create a new policy version
aws iam create-policy-version \
  --policy-arn "arn:aws:iam::$ACCOUNT_ID:policy/$POLICY_NAME" \
  --policy-document file://updated-github-actions-policy.json \
  --set-as-default

if [ $? -eq 0 ]; then
  echo "✅ Policy updated successfully!"
  echo ""
  echo "📋 Added permissions for terraform destroy:"
  echo "  - ecr:DescribeRepositories"
  echo "  - iam:ListRolePolicies"
  echo "  - iam:ListPolicies" 
  echo "  - iam:ListOpenIDConnectProviders"
  echo "  - sns:GetTopicAttributes (via sns:*)"
  echo "  - EKS Pod Identity permissions"
  echo ""
  echo "🎯 You can now run terraform destroy successfully!"
else
  echo "❌ Failed to update policy"
  exit 1
fi

# Clean up temporary file
rm -f updated-github-actions-policy.json

echo "🧹 Cleaned up temporary files"
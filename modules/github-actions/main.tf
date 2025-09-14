# GitHub Actions Secrets Management
# This module creates secrets in AWS Secrets Manager for GitHub Actions to use

# Use existing GitHub Actions OIDC Provider (created by setup-backend workflow)
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# Use existing GitHub Actions IAM Role (created by setup-backend workflow)
data "aws_iam_role" "github_actions" {
  name = "${var.project_name}-github-actions-role"
}

# Use existing GitHub Actions IAM Policy (created by setup-backend workflow)
data "aws_iam_policy" "github_actions" {
  name = "${var.project_name}-github-actions-policy"
}

# Secrets Manager secret for GitHub Actions credentials
resource "aws_secretsmanager_secret" "github_credentials" {
  name                    = "${var.project_name}-github-actions-credentials"
  description             = "AWS credentials for GitHub Actions"
  recovery_window_in_days = 7

  tags = var.tags
}

# Store the credentials in Secrets Manager
resource "aws_secretsmanager_secret_version" "github_credentials" {
  secret_id = aws_secretsmanager_secret.github_credentials.id
  secret_string = jsonencode({
    AWS_REGION              = var.aws_region
    ECR_REPO                = var.ecr_repo_uri
    CLUSTER_NAME            = var.cluster_name
    GITHUB_REPO             = var.github_repo
    GITHUB_ACTIONS_ROLE_ARN = data.aws_iam_role.github_actions.arn
  })
}

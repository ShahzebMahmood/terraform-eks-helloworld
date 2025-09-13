# Security: AWS Secrets Manager for sensitive data
resource "aws_secretsmanager_secret" "app_secrets" {
  name                    = "${var.project_name}-app-secrets"
  description             = "Application secrets for hello-world app"
  recovery_window_in_days = 7  # Security: Short recovery window for demo
  
  tags = var.tags
}

# Security: Store application configuration
resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    NODE_ENV = "production"
    LOG_LEVEL = "info"
    # Add more secrets as needed
  })
}

# Security: IAM policy for pod to access secrets
resource "aws_iam_policy" "secrets_access" {
  name        = "${var.project_name}-secrets-access"
  description = "Policy for accessing application secrets"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.app_secrets.arn
      }
    ]
  })
  
  tags = var.tags
}

# Security: Reference existing IAM role for pod
data "aws_iam_role" "pod_role" {
  name = var.pod_role_name
}

# Security: Attach policy to pod role
resource "aws_iam_role_policy_attachment" "secrets_access" {
  role       = data.aws_iam_role.pod_role.name
  policy_arn = aws_iam_policy.secrets_access.arn
}

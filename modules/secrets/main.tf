# Security: AWS Secrets Manager for sensitive data
resource "aws_secretsmanager_secret" "app_secrets" {
  name                    = "${var.project_name}-app-secrets"
  description             = "Application secrets for hello-world app"
  recovery_window_in_days = 7 # Security: Short recovery window for demo

  tags = var.tags
}

# Security: Store application configuration
resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    NODE_ENV  = "production"
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

# Security: Create IAM role for pod
resource "aws_iam_role" "pod_role" {
  name = var.pod_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:default:hello-world-sa"
            "${replace(var.oidc_provider_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Security: Attach policy to pod role
resource "aws_iam_role_policy_attachment" "secrets_access" {
  role       = aws_iam_role.pod_role.name
  policy_arn = aws_iam_policy.secrets_access.arn
}

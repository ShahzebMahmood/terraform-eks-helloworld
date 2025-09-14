output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions"
  value       = data.aws_iam_role.github_actions.arn
}

output "secrets_manager_secret_arn" {
  description = "ARN of the Secrets Manager secret for GitHub Actions credentials"
  value       = aws_secretsmanager_secret.github_credentials.arn
}

output "secrets_manager_secret_name" {
  description = "Name of the Secrets Manager secret for GitHub Actions credentials"
  value       = aws_secretsmanager_secret.github_credentials.name
}

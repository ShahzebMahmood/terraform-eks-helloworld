output "secrets_arn" {
  description = "ARN of the secrets manager secret"
  value       = aws_secretsmanager_secret.app_secrets.arn
}

output "secrets_name" {
  description = "Name of the secrets manager secret"
  value       = aws_secretsmanager_secret.app_secrets.name
}

output "pod_role_arn" {
  description = "ARN of the IAM role for the pod"
  value       = data.aws_iam_role.pod_role.arn
}

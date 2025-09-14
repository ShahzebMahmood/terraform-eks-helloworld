output "hello_world_pod_identity_role_arn" {
  description = "ARN of the Hello World pod IAM role for Pod Identity"
  value       = aws_iam_role.hello_world_pod_identity.arn
}

output "hello_world_pod_identity_role_name" {
  description = "Name of the Hello World pod IAM role for Pod Identity"
  value       = aws_iam_role.hello_world_pod_identity.name
}

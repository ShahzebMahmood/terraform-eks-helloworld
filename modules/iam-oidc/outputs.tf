output "hello_world_pod_role_arn" {
  description = "ARN of the Hello World pod IAM role"
  value       = aws_iam_role.hello_world_pod.arn
}

output "hello_world_pod_role_name" {
  description = "Name of the Hello World pod IAM role"
  value       = aws_iam_role.hello_world_pod.name
}

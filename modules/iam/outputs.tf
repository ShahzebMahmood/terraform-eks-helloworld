output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "eks_node_role_arn" {
  description = "ARN of the EKS node IAM role"
  value       = aws_iam_role.eks_node_role.arn
}

output "hello_world_pod_role_arn" {
  description = "ARN of the hello world pod IAM role"
  value       = aws_iam_role.hello_world_pod.arn
}

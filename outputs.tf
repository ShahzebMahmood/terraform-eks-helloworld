output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_kubeconfig" {
  description = "Kubeconfig YAML"
  value       = module.eks.kubeconfig
}

output "ecr_repository_uri" {
  description = "ECR repository URI for hello-world image"
  value       = module.ecr.hello_world_repo_uri
}

output "monitoring_dashboard_url" {
  description = "CloudWatch Dashboard URL"
  value       = module.monitoring.dashboard_url
}

output "sns_topic_arn" {
  description = "SNS Topic ARN for alerts"
  value       = module.monitoring.sns_topic_arn
}

output "billing_alarm_arn" {
  description = "Billing alarm ARN for cost monitoring"
  value       = module.billing.billing_alarm_arn
}

output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions"
  value       = module.github_actions.github_actions_role_arn
}

output "secrets_manager_secret_name" {
  description = "Name of the Secrets Manager secret for GitHub Actions credentials"
  value       = module.github_actions.secrets_manager_secret_name
}

output "metrics_server_namespace" {
  description = "Namespace where Metrics Server is deployed"
  value       = module.metrics_server.namespace
}

output "metrics_server_api_service" {
  description = "Metrics Server API service name"
  value       = module.metrics_server.api_service_name
}

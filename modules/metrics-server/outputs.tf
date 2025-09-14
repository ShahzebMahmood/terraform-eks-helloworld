output "namespace" {
  description = "Namespace where Metrics Server is deployed"
  value       = var.namespace
}

output "service_name" {
  description = "Name of the Metrics Server service"
  value       = "metrics-server"
}

output "api_service_name" {
  description = "Name of the Metrics Server API service"
  value       = "v1beta1.metrics.k8s.io"
}

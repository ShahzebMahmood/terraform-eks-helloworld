locals {
  project_name = "TF_AWS_Test"
  environment  = var.environment
  cluster_name = "${local.project_name}-${local.environment}-cluster"
}

// Optional: store the path to your kubeconfig file
locals {
  kubeconfig_path = "${path.module}/kubeconfig-${local.environment}.yaml"
}
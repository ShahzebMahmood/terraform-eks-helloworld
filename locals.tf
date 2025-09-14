locals {
  project_name = "EKS-Terraform-HelloWorld"
  environment  = var.environment
  cluster_name = "${local.project_name}-${local.environment}-cluster"
}

// store the path to your kubeconfig file
locals {
  kubeconfig_path = "${path.module}/kubeconfig-${local.environment}.yaml"
}
variable "namespace" {
  description = "Namespace for Metrics Server"
  type        = string
  default     = "kube-system"
}

variable "create_namespace" {
  description = "Whether to create the namespace"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "Thrive_Cluster_Test"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
    Application = "Hello-World"
  }
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "node_role_name" {
  description = "Name of the IAM role for worker nodes"
  type        = string
  default     = "eks-node-role"
}

variable "cluster_role_name" {
  description = "Name of the IAM role for EKS cluster"
  type        = string
  default     = "eks-cluster-role"
}

variable "eks_oidc_issuer_url" {
  description = "The OIDC issuer URL from the EKS cluster"
  type        = string
  default     = ""
}

variable "eks_oidc_provider_arn" {
  description = "The OIDC provider ARN from the EKS cluster"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

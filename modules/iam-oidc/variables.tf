variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "eks_oidc_issuer_url" {
  description = "The OIDC issuer URL from the EKS cluster"
  type        = string
}

variable "eks_oidc_provider_arn" {
  description = "The OIDC provider ARN from the EKS cluster"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

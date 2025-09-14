variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "secrets_policy_arn" {
  description = "ARN of the secrets access policy"
  type        = string
}

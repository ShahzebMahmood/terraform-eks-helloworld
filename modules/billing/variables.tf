variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "alert_email" {
  description = "Email address for billing alerts (optional)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

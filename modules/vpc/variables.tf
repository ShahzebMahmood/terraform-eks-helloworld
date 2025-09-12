variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets_count" {
  description = "Number of public subnets"
  type        = number
  default     = 2
}

variable "availability_zones" {
  description = "List of availability zones to create subnets in"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}


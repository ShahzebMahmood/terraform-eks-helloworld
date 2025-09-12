variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "thrive-cluster-test"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets_count" {
  description = "Number of public subnets"
  type        = number
  default     = 2
}

variable "availability_zones" {
  description = "List of AZs"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "desired_capacity" {
  description = "Number of worker nodes"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Min number of worker nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Max number of worker nodes"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.micro"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "alert_email" {
  description = "Email address for billing and monitoring alerts (optional)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to assign to the resources."
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
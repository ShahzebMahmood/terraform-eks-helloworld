terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# Security: AWS provider with explicit configuration
provider "aws" {
  region = var.aws_region

  # Security: Ensure proper AWS configuration
  default_tags {
    tags = var.tags
  }
}
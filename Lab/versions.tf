terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.50"
    }
  }
}

locals {
  common_tags = {
    ManagedBy   = "Terraform"
    Environment = var.environment
    Owner       = var.owner
    Project     = var.project
  }
}

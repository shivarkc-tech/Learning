# ─────────────────────────────────────────────
# Global / Meta
# ─────────────────────────────────────────────
variable "aws_region" {
  description = "AWS region to deploy resources into."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment label (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "owner" {
  description = "Team or individual who owns these resources."
  type        = string
  default     = "DevOps"
}

variable "project" {
  description = "Project name used in resource naming and tagging."
  type        = string
  default     = "lab"
}

variable "additional_tags" {
  description = "Optional extra tags to merge onto all resources."
  type        = map(string)
  default     = {}
}

# ─────────────────────────────────────────────
# S3
# ─────────────────────────────────────────────
variable "s3_bucket_name" {
  description = "Globally unique S3 bucket name."
  type        = string
  default     = "terraform-learning-bucket-15062026"
}

variable "s3_force_destroy" {
  description = "Allow Terraform to delete the bucket even when it contains objects."
  type        = bool
  default     = false
}

variable "s3_versioning_enabled" {
  description = "Enable S3 versioning."
  type        = bool
  default     = true
}

# ─────────────────────────────────────────────
# EC2
# ─────────────────────────────────────────────
variable "instance_name" {
  description = "Name tag applied to the EC2 instance."
  type        = string
  default     = "Demo Server"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ebs_volume_size" {
  description = "Root EBS volume size in GB."
  type        = number
  default     = 8
}

variable "key_name" {
  description = "Name of an existing EC2 Key Pair for SSH access. Leave empty to skip."
  type        = string
  default     = ""
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to SSH into the instance. Restrict in production."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "associate_public_ip" {
  description = "Assign a public IP to the EC2 instance."
  type        = bool
  default     = true
}

# ─────────────────────────────────────────────
# VPC / Networking
# ─────────────────────────────────────────────
variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block (e.g. 10.0.0.0/16)."
  }
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"

  validation {
    condition     = can(cidrhost(var.public_subnet_cidr, 0))
    error_message = "public_subnet_cidr must be a valid CIDR block (e.g. 10.0.1.0/24)."
  }
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet."
  type        = string
  default     = "10.0.2.0/24"

  validation {
    condition     = can(cidrhost(var.private_subnet_cidr, 0))
    error_message = "private_subnet_cidr must be a valid CIDR block (e.g. 10.0.2.0/24)."
  }
}



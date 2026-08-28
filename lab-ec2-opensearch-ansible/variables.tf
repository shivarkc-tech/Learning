variable "aws_region" {
  description = "AWS region where lab resources are created."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix for lab resources."
  type        = string
  default     = "lab-opensearch"
}

variable "vpc_cidr" {
  description = "CIDR block for the lab VPC."
  type        = string
  default     = "10.50.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.50.1.0/24"
}

variable "availability_zone" {
  description = "Availability Zone for the lab EC2 instance. Leave null to use the first available AZ."
  type        = string
  default     = null
}

variable "my_ip_cidr" {
  description = "Your public IP in CIDR format for SSH and OpenSearch access. Example: 203.0.113.10/32"
  type        = string
}

variable "create_jenkins_instance" {
  description = "Whether to create a Jenkins lab EC2 instance."
  type        = bool
  default     = true
}

variable "instance_type" {
  description = "EC2 instance type for the OpenSearch lab node."
  type        = string
  default     = "t3.large"
}

variable "jenkins_instance_type" {
  description = "EC2 instance type for the Jenkins lab server."
  type        = string
  default     = "t3.medium"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 10
}

variable "jenkins_root_volume_size" {
  description = "Root EBS volume size in GiB for the Jenkins lab server."
  type        = number
  default     = 10
}

variable "data_volume_size" {
  description = "OpenSearch data EBS volume size in GiB."
  type        = number
  default     = 10
}

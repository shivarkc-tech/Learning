variable "project_name" {
  description = "Name prefix for EC2 resources."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance."
  type        = string
}

variable "security_group_id" {
  description = "Security group ID attached to EC2."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB."
  type        = number
}

variable "data_volume_size" {
  description = "Data EBS volume size in GiB."
  type        = number
}

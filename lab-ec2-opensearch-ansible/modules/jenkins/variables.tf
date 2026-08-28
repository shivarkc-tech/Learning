variable "project_name" {
  description = "Name prefix for Jenkins resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the Jenkins security group."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the Jenkins EC2 instance."
  type        = string
}

variable "my_ip_cidr" {
  description = "Your public IP address in /32 CIDR format."
  type        = string
}

variable "instance_type" {
  description = "Jenkins EC2 instance type."
  type        = string
}

variable "root_volume_size" {
  description = "Jenkins root EBS volume size in GiB."
  type        = number
}

variable "opensearch_sg_id" {
  description = "Security group ID for the OpenSearch target instance."
  type        = string
}

variable "opensearch_key_id" {
  description = "Name of the EC2 key pair used by the OpenSearch target instance."
  type        = string
}

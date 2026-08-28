variable "project_name" {
  description = "Name prefix for security resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "my_ip_cidr" {
  description = "Your public IP address in /32 CIDR format."
  type        = string
}

# ─────────────────────────────────────────────
# S3 Outputs
# ─────────────────────────────────────────────
output "s3_bucket_id" {
  description = "S3 bucket name (ID)."
  value       = aws_s3_bucket.main.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket."
  value       = aws_s3_bucket.main.arn
}

output "s3_bucket_region" {
  description = "AWS region where the bucket was created."
  value       = aws_s3_bucket.main.region
}

# ─────────────────────────────────────────────
# EC2 Outputs
# ─────────────────────────────────────────────
output "instance_id" {
  description = "EC2 instance ID."
  value       = aws_instance.demo.id
}

output "instance_public_ip" {
  description = "Public IPv4 address (empty string if public IP was not assigned)."
  value       = aws_instance.demo.public_ip
}

output "instance_private_ip" {
  description = "Private IPv4 address of the EC2 instance."
  value       = aws_instance.demo.private_ip
}

output "instance_ami" {
  description = "AMI ID resolved at plan time."
  value       = aws_instance.demo.ami
}

output "ssh_command" {
  description = "SSH command to connect to the instance."
  value       = var.public_key_path != "" ? "ssh -i ./Learning_Keypair.pem ubuntu@${aws_instance.demo.public_ip}" : "No key pair configured — use Session Manager instead."
}

output "ssm_connect_command" {
  description = "AWS CLI command to open a Session Manager shell."
  value       = "aws ssm start-session --target ${aws_instance.demo.id} --region ${var.aws_region}"
}

# ─────────────────────────────────────────────
# IAM Outputs
# ─────────────────────────────────────────────
output "iam_role_arn" {
  description = "ARN of the IAM role attached to the instance for SSM."
  value       = aws_iam_role.ssm_role.arn
}

# ─────────────────────────────────────────────
# Security Group Outputs
# ─────────────────────────────────────────────
output "security_group_id" {
  description = "ID of the instance security group."
  value       = aws_security_group.instance.id
}

# ─────────────────────────────────────────────
# VPC / Networking Outputs
# ─────────────────────────────────────────────
output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_id" {
  description = "ID of the public subnet."
  value       = aws_subnet.public.id
}

output "public_subnet_cidr" {
  description = "CIDR block of the public subnet."
  value       = aws_subnet.public.cidr_block
}

output "public_subnet_az" {
  description = "Availability zone of the public subnet."
  value       = aws_subnet.public.availability_zone
}

output "private_subnet_id" {
  description = "ID of the private subnet."
  value       = aws_subnet.private.id
}

output "private_subnet_cidr" {
  description = "CIDR block of the private subnet."
  value       = aws_subnet.private.cidr_block
}

output "private_subnet_az" {
  description = "Availability zone of the private subnet."
  value       = aws_subnet.private.availability_zone
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = aws_internet_gateway.main.id
}

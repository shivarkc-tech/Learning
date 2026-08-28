output "instance_id" {
  description = "EC2 instance ID."
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "EC2 public IP."
  value       = aws_instance.this.public_ip
}

output "ami_id" {
  description = "Ubuntu AMI ID used by the instance."
  value       = data.aws_ami.ubuntu_2204.id
}

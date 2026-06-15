# ─────────────────────────────────────────────
# Global
# ─────────────────────────────────────────────
aws_region  = "us-east-1"
environment = "dev"
owner       = "DevOps"
project     = "lab"

additional_tags = {
  CostCenter = "engineering"
}

# ─────────────────────────────────────────────
# S3
# ─────────────────────────────────────────────
s3_bucket_name        = "myfirstterraform-bucket-15062026"
s3_force_destroy      = false
s3_versioning_enabled = true

# ─────────────────────────────────────────────
# EC2
# ─────────────────────────────────────────────
instance_name   = "Web Server"
instance_type   = "t3.micro"
ebs_volume_size = 8

# SSH key pair — must match the exact name in your AWS console
key_name = "Learning_Keypair"

# Restrict this to your office / VPN IP in production, e.g. ["203.0.113.10/32"]
allowed_ssh_cidrs   = ["0.0.0.0/0"]
associate_public_ip = true

# ─────────────────────────────────────────────
# VPC / Networking
# ─────────────────────────────────────────────
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"

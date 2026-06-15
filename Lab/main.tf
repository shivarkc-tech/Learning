# ═══════════════════════════════════════════════════════════════
# DATA SOURCES
# ═══════════════════════════════════════════════════════════════

# Latest Ubuntu 22.04 LTS (Jammy) AMI from Canonical
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Current caller identity — used to scope IAM resources
data "aws_caller_identity" "current" {}

# ═══════════════════════════════════════════════════════════════
# KEY PAIR
# ═══════════════════════════════════════════════════════════════

# References the existing keypair already in AWS — no re-import needed
# The key_name variable must match exactly what exists in your AWS account

# ═══════════════════════════════════════════════════════════════
# S3 BUCKET
# ═══════════════════════════════════════════════════════════════

resource "aws_s3_bucket" "main" {
  bucket        = var.s3_bucket_name
  force_destroy = var.s3_force_destroy

  tags = merge(local.common_tags, var.additional_tags, {
    Name = var.s3_bucket_name
  })
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Server-side encryption (AES-256)
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Versioning
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = var.s3_versioning_enabled ? "Enabled" : "Suspended"
  }
}

# Lifecycle — abort stale multipart uploads after 7 days
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "abort-incomplete-multipart"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# ═══════════════════════════════════════════════════════════════
# IAM — SESSION MANAGER (SSM)
# ═══════════════════════════════════════════════════════════════

# IAM Role that the EC2 instance will assume
resource "aws_iam_role" "ssm_role" {
  name        = "${var.project}-${var.environment}-ec2-ssm-role"
  description = "Allows EC2 to call AWS SSM Session Manager"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.common_tags, var.additional_tags, {
    Name = "${var.project}-${var.environment}-ec2-ssm-role"
  })
}

# Attach the AWS-managed SSM policy
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance profile wrapping the role
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.project}-${var.environment}-ec2-ssm-profile"
  role = aws_iam_role.ssm_role.name

  tags = merge(local.common_tags, var.additional_tags, {
    Name = "${var.project}-${var.environment}-ec2-ssm-profile"
  })
}

# ═══════════════════════════════════════════════════════════════
# SECURITY GROUP
# ═══════════════════════════════════════════════════════════════

resource "aws_security_group" "instance" {
  name        = "${var.project}-${var.environment}-instance-sg"
  description = "Security group for Demo Server - SSH ingress + unrestricted egress"
  vpc_id      = aws_vpc.main.id   # Attach to the custom VPC

  tags = merge(local.common_tags, var.additional_tags, {
    Name = "${var.project}-${var.environment}-instance-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# SSH inbound rule (separate resource — avoids plan-time conflicts on updates)
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.instance.id
  description       = "SSH access"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22

  # Create one rule per CIDR supplied in var.allowed_ssh_cidrs
  for_each  = toset(var.allowed_ssh_cidrs)
  cidr_ipv4 = each.value

  tags = merge(local.common_tags, var.additional_tags, {
    Name = "allow-ssh-${replace(each.value, "/", "-")}"
  })
}

# Allow all outbound traffic (required for SSM, package installs, etc.)
resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.instance.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = merge(local.common_tags, var.additional_tags, {
    Name = "allow-all-outbound"
  })
}

# ═══════════════════════════════════════════════════════════════
# EC2 INSTANCE
# ═══════════════════════════════════════════════════════════════

resource "aws_instance" "demo" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id   # Launch into the public subnet
  vpc_security_group_ids      = [aws_security_group.instance.id]
  key_name                    = var.key_name != "" ? var.key_name : null
  associate_public_ip_address = var.associate_public_ip
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name

  # Root EBS volume — 8 GB, encrypted
  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.ebs_volume_size
    encrypted             = true
    delete_on_termination = true

    tags = merge(local.common_tags, var.additional_tags, {
      Name = "${var.instance_name}-root-vol"
    })
  }

  # Bootstrap: install SSM agent (pre-installed on Ubuntu 22.04 official AMIs,
  # but this ensures it's running and up to date)
  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail
    apt-get update -y
    apt-get install -y snapd
    snap install amazon-ssm-agent --classic || true
    systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
    systemctl start  snap.amazon-ssm-agent.amazon-ssm-agent.service
  EOF

  metadata_options {
    http_tokens                 = "required"  # IMDSv2 only — security best practice
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring = true

  tags = merge(local.common_tags, var.additional_tags, {
    Name = var.instance_name
  })

  # Prevent accidental replacement when a new AMI is published
  lifecycle {
    ignore_changes = [ami, user_data]
  }
}

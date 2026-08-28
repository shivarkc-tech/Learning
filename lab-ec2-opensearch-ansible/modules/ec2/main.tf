data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "private_key" {
  filename        = "${path.root}/generated/${var.project_name}.pem"
  content         = tls_private_key.this.private_key_pem
  file_permission = "0600"
}

resource "aws_key_pair" "this" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.this.public_key_openssh
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.ubuntu_2204.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted   = true
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  ebs_block_device {
    device_name           = "/dev/sdf"
    encrypted             = true
    volume_size           = var.data_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "${var.project_name}-ec2"
    Role = "opensearch-lab"
  }

  depends_on = [local_sensitive_file.private_key]
}

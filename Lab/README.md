# Terraform Lab — Enterprise Infrastructure

Provisions an S3 bucket and an Ubuntu EC2 instance with SSH + AWS Systems Manager Session Manager access.

## Resources Created

| Resource | Name / Value |
|---|---|
| S3 Bucket | `Myfirstterraform-bucket-15062026` |
| EC2 Instance | `Demo Server` — `t3.micro` Ubuntu 22.04 LTS |
| Root EBS Volume | 8 GB gp3, encrypted |
| Security Group | SSH (port 22) inbound, all outbound |
| IAM Role + Profile | `AmazonSSMManagedInstanceCore` for Session Manager |

## File Structure

```
Lab/
├── versions.tf       # Terraform + provider version constraints, common locals
├── provider.tf       # AWS provider configuration with default_tags
├── variables.tf      # All input variable declarations with validation
├── main.tf           # Resource definitions (S3, EC2, SG, IAM)
├── outputs.tf        # Useful output values
└── terraform.tfvars  # Environment-specific values
```

## Prerequisites

- Terraform >= 1.5.0
- AWS credentials configured (`aws configure` or environment variables)
- AWS CLI v2 (for Session Manager connect command)
- [Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html) installed locally

## Usage

```bash
# Initialise providers
terraform init

# Preview changes
terraform plan

# Apply
terraform apply

# Connect via Session Manager (no SSH key needed)
aws ssm start-session --target <instance-id> --region us-east-1

# Connect via SSH (if key_name is set)
ssh -i ~/.ssh/your-key.pem ubuntu@<public-ip>

# Tear down
terraform destroy
```

## Security Notes

- IMDSv2 is enforced on the EC2 instance (no IMDSv1 access).
- The S3 bucket blocks all public access and uses AES-256 server-side encryption.
- S3 versioning is enabled by default.
- Restrict `allowed_ssh_cidrs` to your IP/VPN range in production.
- Set `key_name = ""` and rely on Session Manager for keyless, auditable shell access.

## Tags Applied to All Resources

| Tag | Value |
|---|---|
| ManagedBy | Terraform |
| Environment | dev (configurable) |
| Owner | DevOps (configurable) |
| Project | lab (configurable) |

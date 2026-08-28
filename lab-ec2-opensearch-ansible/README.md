# Lab EC2 OpenSearch Deployment

This project creates a complete lab environment from scratch:

- New VPC
- Public subnet
- Internet gateway and route table
- Security group
- SSH key pair
- Optional Jenkins EC2 instance
- Ubuntu 22.04 EC2 instance
- Extra EBS data volume
- Generated Ansible inventory
- OpenSearch installed and configured by Ansible
- OpenSearch Dashboards installed and configured by Ansible

This deploys **self-managed OpenSearch on EC2**, not Amazon OpenSearch Service.

## 1. Prerequisites

Install these on your laptop or jump host:

```bash
terraform version
aws --version
ansible --version
```

Configure AWS credentials:

```bash
aws configure
```

## 2. Configure Variables

Copy the example file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Find your public IP:

```bash
curl https://checkip.amazonaws.com
```

Edit `terraform.tfvars` and replace:

```hcl
my_ip_cidr = "YOUR_PUBLIC_IP/32"
```

Example:

```hcl
my_ip_cidr = "203.0.113.10/32"
```

## 3. Create AWS Infrastructure

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

After apply, Terraform creates:

```text
generated/lab-opensearch.pem
generated/lab-opensearch-jenkins.pem
ansible/inventory.ini
```

It also prints the SSH command, OpenSearch URL, Dashboards URL, Jenkins SSH command, and Jenkins URL.

## 4. Install Ansible Collections

```bash
cd ansible
ansible-galaxy collection install -r requirements.yml
```

## 5. Test SSH Connectivity

```bash
ansible opensearch -m ping
```

## 6. Install OpenSearch And Dashboards

```bash
ansible-playbook playbooks/install-opensearch.yml
```

The playbook installs:

- OpenSearch `2.15.0`
- OpenSearch Dashboards `2.15.0`
- Correct OpenSearch `2.x` APT signing key
- Separate APT repositories for OpenSearch and OpenSearch Dashboards
- Lab config with security disabled

## 7. Verify OpenSearch

Use the Terraform output URL, or run:

```bash
curl http://EC2_PUBLIC_IP:9200
```

You should receive OpenSearch cluster information in JSON format.

Open Dashboards in your browser:

```text
http://EC2_PUBLIC_IP:5601
```

Because this is a lab config, Dashboards should open without username/password.

## 8. Optional Jenkins Pipeline Test

This package can also create one Jenkins EC2 instance for testing a Git-to-Jenkins deployment flow.

Open the Jenkins URL from Terraform output:

```bash
terraform output jenkins_url
```

Get the initial Jenkins admin password:

```bash
ssh -i generated/lab-opensearch-jenkins.pem ubuntu@JENKINS_PUBLIC_IP
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

In Jenkins, create a Pipeline job:

```text
New Item -> Pipeline -> Pipeline script from SCM -> Git
Script Path: Jenkinsfile
```

When running this repo from Jenkins, the included `Jenkinsfile` sets:

```text
TF_VAR_create_jenkins_instance=false
```

That prevents Jenkins from trying to create another Jenkins server during the pipeline run.

For the Jenkins build parameter `MY_IP_CIDR`, use the Jenkins server public IP in `/32` format:

```bash
curl https://checkip.amazonaws.com
```

Example:

```text
44.192.10.20/32
```

## 9. Rerun After A Failed Install

If package installation was interrupted, run:

```bash
ansible opensearch -b -m shell -a 'DEBIAN_FRONTEND=noninteractive OPENSEARCH_INITIAL_ADMIN_PASSWORD="GkLabSearch@2026!" dpkg --configure -a'
ansible-playbook playbooks/install-opensearch.yml
```

## 10. Destroy Lab Resources

From the Terraform root directory:

```bash
terraform destroy
```

## Lab Security Note

For lab simplicity, this playbook disables the OpenSearch Security plugin:

```yaml
plugins.security.disabled: true
```

The security group restricts SSH, OpenSearch API, and Dashboards access to your `my_ip_cidr`.

Do not use this exact configuration for production.

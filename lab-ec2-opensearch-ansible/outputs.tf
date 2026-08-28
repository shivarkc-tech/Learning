output "instance_id" {
  description = "EC2 instance ID."
  value       = module.ec2.instance_id
}

output "public_ip" {
  description = "Public IP address of the OpenSearch EC2 instance."
  value       = module.ec2.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to the lab instance."
  value       = "ssh -i ${abspath("${path.module}/generated/${var.project_name}.pem")} ubuntu@${module.ec2.public_ip}"
}

output "opensearch_url" {
  description = "OpenSearch lab endpoint."
  value       = "http://${module.ec2.public_ip}:9200"
}

output "opensearch_dashboards_url" {
  description = "OpenSearch Dashboards lab endpoint."
  value       = "http://${module.ec2.public_ip}:5601"
}

output "ansible_inventory" {
  description = "Generated Ansible inventory file."
  value       = local_file.ansible_inventory.filename
}

output "jenkins_public_ip" {
  description = "Public IP address of the Jenkins lab server."
  value       = var.create_jenkins_instance ? module.jenkins[0].public_ip : null
}

output "jenkins_url" {
  description = "Jenkins lab URL."
  value       = var.create_jenkins_instance ? "http://${module.jenkins[0].public_ip}:8080" : null
}

output "jenkins_ssh_command" {
  description = "SSH command to connect to the Jenkins lab server."
  value       = var.create_jenkins_instance ? "ssh -i ${abspath("${path.module}/generated/${var.project_name}-jenkins.pem")} ubuntu@${module.jenkins[0].public_ip}" : null
}

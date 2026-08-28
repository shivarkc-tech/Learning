#!/usr/bin/env bash
set -euo pipefail

terraform init
terraform validate
terraform apply

cd ansible
ansible-galaxy collection install -r requirements.yml
ansible opensearch -m ping
ansible-playbook playbooks/install-opensearch.yml

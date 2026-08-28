#!/usr/bin/env bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y ca-certificates curl gnupg unzip software-properties-common git ansible openjdk-17-jre

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | gpg --dearmor --batch --yes -o /etc/apt/keyrings/jenkins.gpg
chmod 0644 /etc/apt/keyrings/jenkins.gpg
echo "deb [signed-by=/etc/apt/keyrings/jenkins.gpg] https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list

curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor --batch --yes -o /etc/apt/keyrings/hashicorp.gpg
chmod 0644 /etc/apt/keyrings/hashicorp.gpg
echo "deb [signed-by=/etc/apt/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com jammy main" > /etc/apt/sources.list.d/hashicorp.list

apt-get update
apt-get install -y jenkins terraform

curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install --update

mkdir -p /var/lib/jenkins/.ssh
chown -R jenkins:jenkins /var/lib/jenkins/.ssh
chmod 0700 /var/lib/jenkins/.ssh

systemctl enable jenkins
systemctl restart jenkins

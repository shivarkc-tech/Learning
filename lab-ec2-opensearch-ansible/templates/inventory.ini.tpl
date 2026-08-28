[opensearch]
opensearch-lab ansible_host=${public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${private_key_path}

[opensearch:vars]
ansible_python_interpreter=/usr/bin/python3

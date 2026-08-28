module "network" {
  source = "./modules/network"

  project_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  availability_zone  = var.availability_zone
}

module "security" {
  source = "./modules/security"

  project_name = var.project_name
  vpc_id       = module.network.vpc_id
  my_ip_cidr   = var.my_ip_cidr
}

module "ec2" {
  source = "./modules/ec2"

  project_name      = var.project_name
  subnet_id         = module.network.public_subnet_id
  security_group_id = module.security.security_group_id
  instance_type     = var.instance_type
  root_volume_size  = var.root_volume_size
  data_volume_size  = var.data_volume_size
}

module "jenkins" {
  source = "./modules/jenkins"
  count  = var.create_jenkins_instance ? 1 : 0

  project_name      = var.project_name
  subnet_id         = module.network.public_subnet_id
  vpc_id            = module.network.vpc_id
  my_ip_cidr        = var.my_ip_cidr
  instance_type     = var.jenkins_instance_type
  root_volume_size  = var.jenkins_root_volume_size
  opensearch_sg_id  = module.security.security_group_id
  opensearch_key_id = "${var.project_name}-key"
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/ansible/inventory.ini"

  content = templatefile("${path.module}/templates/inventory.ini.tpl", {
    public_ip        = module.ec2.public_ip
    private_key_path = abspath("${path.module}/generated/${var.project_name}.pem")
  })
}

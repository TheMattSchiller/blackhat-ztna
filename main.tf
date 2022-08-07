locals {
  public_subnet_a   = "10.0.0.0/24"
  public_subnet_b   = "10.0.1.0/24"
  private_subnet  = "10.0.2.0/24"
  priv_ssh_key_path = "~/.ssh/id_rsa"
  pub_ssh_key_path  = "~/.ssh/id_rsa.pub"
}

module "network" {
  source           = "./1-network"
  public_subnet  = local.public_subnet_a
  public_subnet_b  = local.public_subnet_b
  private_subnet = local.private_subnet
}

module "target" {
  source    = "./2-target"
  subnet_id = module.network.private_subnet_id
  key_name  = aws_key_pair.boundary.key_name
  ami       = data.aws_ami.ubuntu.id
}

module "controller" {
  source            = "./3-controller"
  priv_ssh_key_path = local.priv_ssh_key_path
  pub_ssh_key_path  = local.pub_ssh_key_path
  public_subnet     = module.network.public_subnet_id
  public_subnet_b   = module.network.public_subnet_b_id
  vpc_id            = module.network.vpc_id
  ami               = data.aws_ami.ubuntu.id
  ssh_key_name      = aws_key_pair.boundary.key_name
}

module "worker" {
  source = "./4-worker"
  private_subnet = module.network.private_subnet_id
  aws_iam_instance_profile = module.controller.aws_iam_instance_profile
  private_key_pem = module.controller.private_key_pem
  cert_pem = module.controller.cert_pem
  kms_root_key_id = module.controller.kms_root_key_id
  kms_recovery_key_id = module.controller.kms_recovery_key_id
  kms_worker_auth_key_id = module.controller.kms_worker_auth_key_id
  ssh_key_name = aws_key_pair.boundary.key_name
  controller_ip = module.controller.controller_public_ip
  db_endpoint = module.controller.db_endpoint
  vpc_id = module.network.vpc_id
  ami = data.aws_ami.ubuntu.id
}

module "controller_config" {
  source = "./5-controller-config"
  url = module.controller.boundary_lb_url
  kms_recovery_key_id = module.controller.kms_recovery_key_id
  organization = "blackhat"
}

module "users" {
  source = "./6-users"
  url = module.controller.boundary_lb_url
  kms_recovery_key_id = module.controller.kms_recovery_key_id
  organization = "blackhat"
}

module "roles" {
  source = "./7-roles"
  url = module.controller.boundary_lb_url
  kms_recovery_key_id = module.controller.kms_recovery_key_id
  global_scope = module.controller_config.global_scope
  org_scope = module.controller_config.org_scope
}

module "catalog" {
  source = "./8-catalog"
  url = module.controller.boundary_lb_url
  kms_recovery_key_id = module.controller.kms_recovery_key_id
  org_scope = module.controller_config.org_scope
}

module "web-target" {
  source = "./9-web-target"
  url = module.controller.boundary_lb_url
  kms_recovery_key_id = module.controller.kms_recovery_key_id
  org_scope = module.controller_config.org_scope
  target_address = module.target.private_ip
}

module "ssh-target" {
  source = "./10-ssh-target"
  url = module.controller.boundary_lb_url
  kms_recovery_key_id = module.controller.kms_recovery_key_id
  org_scope = module.controller_config.org_scope
  host_source_ids = [module.web-target.host_id]
}
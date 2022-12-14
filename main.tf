locals {
  public_subnet_a   = "10.0.0.0/24"
  public_subnet_b   = "10.0.1.0/24"
  private_subnet    = "10.0.2.0/24"
  priv_ssh_key_path = "~/.ssh/id_rsa"
  pub_ssh_key_path  = "~/.ssh/id_rsa.pub"
}

module "network" {
  source          = "./1-network"
  public_subnet   = local.public_subnet_a
  public_subnet_b = local.public_subnet_b
  private_subnet  = local.private_subnet
}

module "target" {
  source             = "./2-target"
  subnet_id          = module.network.private_subnet_id
  key_name           = aws_key_pair.boundary.key_name
  ami                = data.aws_ami.ubuntu.id
  vpc_security_group = module.worker.security_group
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
  source                   = "./4-worker"
  public_subnet            = module.network.public_subnet_id
  aws_iam_instance_profile = module.controller.aws_iam_instance_profile
  private_key_pem          = module.controller.private_key_pem
  cert_pem                 = module.controller.cert_pem
  kms_root_key_id          = module.controller.kms_root_key_id
  kms_recovery_key_id      = module.controller.kms_recovery_key_id
  kms_worker_auth_key_id   = module.controller.kms_worker_auth_key_id
  ssh_key_name             = aws_key_pair.boundary.key_name
  controller_ip            = module.controller.controller_public_ip
  db_endpoint              = module.controller.db_endpoint
  vpc_id                   = module.network.vpc_id
  ami                      = data.aws_ami.ubuntu.id
}

module "controller-config" {
  source              = "./5-controller-config"
  url                 = module.controller.boundary_lb_url
  kms_recovery_key_id = module.controller.kms_recovery_key_id
  organization        = "blackhat"
}

module "users" {
  source              = "./6-users"
  url                 = module.controller.boundary_lb_url
  kms_recovery_key_id = module.controller.kms_recovery_key_id
  auth_method         = module.controller-config.auth_method
  org_scope           = module.controller-config.org_scope
  organization        = "blackhat"
}

module "roles" {
  source              = "./7-roles"
  url                 = module.controller.boundary_lb_url
  kms_recovery_key_id = module.controller.kms_recovery_key_id
  global_scope        = module.controller-config.global_scope
  org_scope           = module.controller-config.org_scope
  standarduser        = module.users.standarduser
  adminuser           = module.users.adminuser
  project_scope       = module.controller-config.project_scope
}

module "catalog" {
  source              = "./8-catalog"
  url                 = module.controller.boundary_lb_url
  kms_recovery_key_id = module.controller.kms_recovery_key_id
  org_scope           = module.controller-config.project_scope
}

module "web-target" {
  source              = "./9-web-target"
  url                 = module.controller.boundary_lb_url
  kms_recovery_key_id = module.controller.kms_recovery_key_id
  org_scope           = module.controller-config.project_scope
  host_catalog_id     = module.catalog.backend_servers
  priv_ssh_key_path   = local.priv_ssh_key_path
  pub_ssh_key_path    = local.pub_ssh_key_path
  private_subnet      = module.network.private_subnet_id
  ami                 = data.aws_ami.ubuntu.id
  ssh_key_name        = aws_key_pair.boundary.key_name
  vpc_security_group  = module.worker.security_group
  controller_ip       = module.controller.controller_public_ip
}

module "rdp-target" {
  source              = "./10-rdp-target"
  url                 = module.controller.boundary_lb_url
  kms_recovery_key_id = module.controller.kms_recovery_key_id
  project_scope       = module.controller-config.project_scope
  host_catalog_id     = module.catalog.backend_servers
  priv_ssh_key_path   = local.priv_ssh_key_path
  pub_ssh_key_path    = local.pub_ssh_key_path
  private_subnet      = module.network.private_subnet_id
  ami                 = data.aws_ami.ubuntu.id
  ssh_key_name        = aws_key_pair.boundary.key_name
  vpc_security_group  = module.worker.security_group
  controller_ip       = module.controller.controller_public_ip
}
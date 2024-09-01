# --- root/main.tf ---

provider "aws" {
  region = local.location
  profile = "default"
}

locals {
  instance_type = "t2.micro"
  location      = "ap-south-1"
  vpc_cidr      = "10.123.0.0/16"
}

module "networking" {
  source            = "../modules/networking"
  vpc_cidr          = local.vpc_cidr
  access_ip         = var.access_ip
  ec2_instance_connect_ip = var.ec2_instance_connect_ip
  public_sn_count   = 2
  private_sn_count  = 1
}

module "roles"{
  source = "../modules/roles"
}

module "compute" {
  source                  = "../modules/compute"
  custom_webserver_sg         = module.networking.custom_webserver_sg
  custom_ansible_sg          = module.networking.custom_ansible_sg
  private_subnets         = module.networking.private_subnets
  instance_type           = local.instance_type
  webserver_instance_profile = module.roles.terraform_webserver_ssm_instance_profile
  ansible_instance_profile = module.roles.terraform_ansible_ssm_s3_instance_profile
  key_name                = "K8"
  lb_tg_name              = module.loadbalancing.lb_tg_name
  lb_tg_arn                   = module.loadbalancing.lb_tg_arn
  custom_ngw                  = module.networking.aws_nat_gateway
}

module "loadbalancing" {
  source                  = "../modules/loadbalancing"
  lb_sg                   = module.networking.custom_lb_sg
  public_subnets          = module.networking.public_subnets
  tg_port                 = 80
  tg_protocol             = "HTTP"
  vpc_id                  = module.networking.vpc_id
  webserver_asg                 = module.compute.webserver_asg
  listener_port           = 80
  listener_protocol       = "HTTP"
}
module "systemsmanager" {
  source                  = "../modules/systemsmanager"
}

module "eventbridge" {
  source                  = "../modules/eventbridge"
  custom_asg_event_role_arn = module.roles.custom_asg_event_role_arn
  document_name = module.systemsmanager.document_name
}
# --- compute/variables.tf ---

variable "custom_webserver_sg" {}
variable "custom_ansible_sg" {}
variable "private_subnets" {}
variable "key_name" {}
variable "webserver_instance_profile" {}
variable "ansible_instance_profile" {}
variable "lb_tg_name" {}
variable "lb_tg_arn" {}
variable "custom_ngw" {}
variable "instance_type" {
  type = string
}
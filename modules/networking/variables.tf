# --- networking/variables.tf ---

variable "vpc_cidr" {
  type = string
}

variable "public_sn_count" {
  type = number
}

variable "private_sn_count" {
  type = number
}

variable "access_ip" {
  type = string
}

variable "ec2_instance_connect_ip" {
  type = string
}
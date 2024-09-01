# --- root/variables.tf ---

variable "access_ip" {
  type = string
  default = "103.212.153.13/32"
}

variable "ec2_instance_connect_ip" {
  type = string
  default = "13.233.177.0/29"
}

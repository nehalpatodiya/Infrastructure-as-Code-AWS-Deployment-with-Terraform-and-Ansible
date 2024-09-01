# --- networking/outputs.tf ---

output "vpc_id" {
  value = aws_vpc.custom_vpc.id
}

output "custom_lb_sg" {
  value = aws_security_group.custom_lb_sg.id
}

output "custom_ansible_sg" {
  value = aws_security_group.custom_ansible_sg.id
}

output "custom_webserver_sg" {
  value = aws_security_group.custom_webserver_sg.id
}

output "public_subnets" {
  value = aws_subnet.custom_public_subnets.*.id
}

output "aws_nat_gateway" {
  value = aws_nat_gateway.custom_ngw.id
}

output "private_subnets" {
  value = aws_subnet.custom_private_subnets.*.id
}
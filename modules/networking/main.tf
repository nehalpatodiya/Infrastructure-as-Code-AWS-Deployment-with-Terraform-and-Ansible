# --- networking/main.tf ---


### CUSTOM VPC CONFIGURATION

resource "aws_vpc" "custom_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "custom_vpc"
  }
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_availability_zones" "available" {
}

### CUSTOM INTERNET GATEWAY

resource "aws_internet_gateway" "custom_internet_gateway" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "custom_internet_gateway"
  }
  lifecycle {
    create_before_destroy = true
  }
}

### PUBLIC SUBNETS (LOAD BALANCER) AND ASSOCIATED ROUTE TABLES

resource "aws_subnet" "custom_public_subnets" {
  count                   = var.public_sn_count
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.123.${10 + count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "custom_public_${count.index + 1}"
  }
}

resource "aws_route_table" "custom_public_rt" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "custom_public"
  }
}

resource "aws_route" "default_public_route" {
  route_table_id         = aws_route_table.custom_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.custom_internet_gateway.id
}

resource "aws_route_table_association" "custom_public_assoc" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.custom_public_subnets.*.id[count.index]
  route_table_id = aws_route_table.custom_public_rt.id
}


### EIP AND NAT GATEWAY

resource "aws_eip" "custom_nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "custom_ngw" {
  allocation_id     = aws_eip.custom_nat_eip.id
  subnet_id         = aws_subnet.custom_public_subnets[0].id
}

### PRIVATE SUBNETS (WEB SERVERS) AND ASSOCIATED ROUTE TABLES

resource "aws_subnet" "custom_private_subnets" {
  count                   = var.private_sn_count
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.123.${20 + count.index}.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "custom_private_${count.index + 1}"
  }
}

resource "aws_route_table" "custom_private_rt" {
  vpc_id = aws_vpc.custom_vpc.id
  
  tags = {
    Name = "custom_private"
  }
}

resource "aws_route" "default_private_route" {
  route_table_id         = aws_route_table.custom_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.custom_ngw.id
}


resource "aws_route_table_association" "custom_private_assoc" {
  count          = var.private_sn_count
  route_table_id = aws_route_table.custom_private_rt.id
  subnet_id      = aws_subnet.custom_private_subnets.*.id[count.index]
}


### SECURITY GROUPS

resource "aws_security_group" "custom_lb_sg" {
  name        = "custom_lb_sg"
  description = "Allow Inbound HTTP Traffic"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Inbound HTTP Traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "custom_ansible_sg" {
  name        = "custom_ansible_sg"
  description = "ansible sg"
  vpc_id      = aws_vpc.custom_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "custom_webserver_sg" {
  name        = "custom_webserver_sg"
  description = "sg for webservers"
  vpc_id      = aws_vpc.custom_vpc.id



  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.custom_lb_sg.id]
    description = "Allow Traffic from LB"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.custom_ansible_sg.id]
    description = "Allow SSH from Ansible SG"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
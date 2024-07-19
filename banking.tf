#Initialize Terraform
terraform {
  required_provider {
    aws = {
      source = "hashicorp/aws"
      version = ">=4.0"
    }
}
}
#configure the AWS provider
provider "aws" {
  region     = "us-east-2"
}
# Create a VPC
resource "aws_vpc" "mproj-vpc" {
  cidr_block       = "10.0.0.0/16"
}

# create an Internet Gateway
resource "aws_internet_gateway" "proj-ig" {
  vpc_id = aws_vpc.proj-vpc.id
  tags = {
    Name = "gateway1"
  }
}

# Setting up the Route Table
resource "aws_route_table" "proj-rt" {
  vpc_id = aws_vpc.proj-vpc.id
  route {
#pointing to the internet
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.proj-ig.id
  }
route {
 ipv6_cidr_block = "::/0"
 gateway_id = aws_internet_gateway.proj-ig.id
}
  tags = {
    Name = "rt1"
  }
}

# setting up the Subnet 
resource "aws_subnet" "proj-subnet" {
  vpc_id     = aws_vpc.proj-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2"
  tags = {
    Name = "subnet1"
  }
}

# Associating the subnet with the route table
resource "aws_route_table_association" "proj-rt-sub-assoc" {
subnet_id      = aws_subnet.proj-subnet.id
route_table_id = aws_route_table.proj-rt.id
}

#creating security group
resource "aws_security_group" "proj-5g" { 
name = "proj-5g" 
description = "Enable web traffic for the project" 
vpc_id = aws_vpc.proj-vpc.id 
ingress { 
from_port = 0 
to_port   = 0 
protocol = "-1" 
cidr_blocks = ["0.0.0.0/0"] 
} 


egress { 
from_port = 0 
to_port   = 0 
protocol = "-1" 
cidr_blocks = ["0.0.0.0/0"] 
} 
ingress { 
description = "HTTPS traffic"
from_port  = 443
to_port    = 443
protocol   = "tcp" 
cidr_blocks = ["0.0.0.0/0"] 
} 
ingress { 
description = "HTTPS traffic"
from_port  = 0
to_port    = 65000
protocol   = "tcp" 
cidr_blocks = ["0.0.0.0/0"] 
} 
ingress { 
description = "Allow port 80 inbound"
from_port  = 80
to_port    = 80
protocol   = "tcp" 
cidr_blocks = ["0.0.0.0/0"] 
} 
egress { 
from_port = 0 
to_port   = 0 
protocol = "-1" 
cidr_blocks = ["0.0.0.0/0"]
ipv6_cidr_blocks = ["::/0"]
}
tags = { 
Name = "proj-sg1" 
} 
} 

#creating a new network interface
resource "aws_network_interface" Pproj-ni" {
subnet_id - aws_subnet.proj-subnet.id
private_ips = ["10.0.1.10"]
security_groups = [aws_security_group.proj-sg.id]
}

#Attaching an elastic IP to the network interface
resource "aws_eip" "proj-eip" {
vpc = true
network_interface - aws_network_interface.proj-ni.id
associate_with_private_ip - "10.0.1.10"
}

# Create an ubuntu EC2 Instance
resource "aws_instance" "prod-server" {
  ami  = "ami-0f58b397bc5c1f2e8"
  instance_type = "t2.micro"
availability_zone = "us-east-2"
  key_name = "Tomcat"
network_interface {
device_index - 0
network_interface_id - aws_network_interface.proj-ni.id
}
user_data = <<-EOF
#!/bin/bash
     sudo apt-get update -y
EOF
tags = {
Name - "prod-server"
}
}

  


 

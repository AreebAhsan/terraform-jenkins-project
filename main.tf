provider "aws" {
  region = "ap-south-1" # Specify your desired AWS region
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "192.168.0.0/16" # Set your desired CIDR block for the VPC
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "Terra-VPC"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "terra_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create Public Subnets with different CIDR ranges
resource "aws_subnet" "public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.my_vpc.id

  # Define unique CIDR blocks for each subnet
  cidr_block              = element(["192.168.0.0/18", "192.168.64.0/18"], count.index)

  availability_zone       = element(["ap-south-1a", "ap-south-1b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "Terra Public Subnet ${count.index + 1}"
  }
}

# Create Private Subnets with different CIDR ranges
resource "aws_subnet" "private_subnet" {
  count                   = 4
  vpc_id                  = aws_vpc.my_vpc.id

  # Define unique CIDR blocks for each subnet
  cidr_block              = element(["192.168.128.0/19", "192.168.160.0/19", "192.168.192.0/19", "192.168.224.0/19"], count.index)

  availability_zone       = element(["ap-south-1a", "ap-south-1b", "ap-south-1a", "ap-south-1b"], count.index)

  tags = {
    Name = "terra Private Subnet ${count.index + 1}"
  }
}

# Create Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "Terra Public RT"
  }
}

# Create Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "Terra Private RT"
  }
}

# Create Route to Internet Gateway in Public Route Table
resource "aws_route" "route_to_igw" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.terra_igw.id
}

# Associate Public Subnets with the Public Route Table
resource "aws_route_table_association" "public_subnet_association" {
  count          = 2
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate Private Subnets with the Private Route Table
resource "aws_route_table_association" "private_subnet_association" {
  count          = 4
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

#this file consists of code for instances and sg

resource "aws_instance" "one" {
  ami             = "ami-0899663faf239dd8a"
  instance_type   = "t2.micro"
  subnet_id = "${aws_subnet.public_subnet[0].id}"
  key_name        = "ALKeyPair"
  availability_zone = "ap-south-1a"
  user_data       = <<EOF
#!/bin/bash
sudo -i
yum install httpd -y
systemctl start httpd
chkconfig httpd on
echo "This is my app created by terraform infrastructurte server-1" > /var/www/html/index.html
EOF
  tags = {
    Name = "web-server-1"
  }
}

resource "aws_instance" "two" {
  ami             = "ami-0899663faf239dd8a"
  instance_type   = "t2.micro"
  subnet_id = "${aws_subnet.public_subnet[1].id}"
  key_name        = "ALKeyPair"
  availability_zone = "ap-south-1b"
  user_data       = <<EOF
#!/bin/bash
sudo -i
yum install httpd -y
systemctl start httpd
chkconfig httpd on
echo "This is my website created by terraform infrastructurte server-2" > /var/www/html/index.html
EOF
  tags = {
    Name = "web-server-2"
  }
}

resource "aws_instance" "three" {
  ami             = "ami-0899663faf239dd8a"
  instance_type   = "t2.micro"
  subnet_id = "${aws_subnet.private_subnet[0].id}"
  key_name        = "ALKeyPair"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "app-server-1"
  }
}

resource "aws_instance" "four" {
  ami             = "ami-0899663faf239dd8a"
  instance_type   = "t2.micro"
  subnet_id = "${aws_subnet.private_subnet[1].id}"
  key_name        = "ALKeyPair"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "app-server-2"
  }
}

resource "aws_security_group" "five" {
  name = "terra-sg"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80:
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "six" {
  bucket = "areebterrabucket04"
}

resource "aws_iam_user" "seven" {
for_each = var.user_names
name = each.value
}

variable "user_names" {
description = "*"
type = set(string)
default = ["user1", "user2", "user3", "user4"]
}

resource "aws_ebs_volume" "eight" {
 availability_zone = "ap-south-1a"
  size = 20
  tags = {
    Name = "terra-ebs"
  }
}

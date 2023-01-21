##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  region     = "us-east-1"
}

##################################################################################
# DATA
##################################################################################

data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

variable "vpc" {
  type  = string
}

variable "cidr" {
  type  = string
}

variable "az" {
  type  = string
}

##################################################################################
# RESOURCES
##################################################################################

resource "aws_subnet" "whiskey_subnet" {
  cidr_block              = var.cidr
  vpc_id                  = var.vpc
  availability_zone       = var.az
  map_public_ip_on_launch = true
}

# SECURITY GROUPS #
# Nginx security group 
resource "aws_security_group" "nginx-sg" {
  name   = "nginx_sg"
  vpc_id = var.vpc
 
  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Attach Disc
resource "aws_volume_attachment" "ebs_attach1" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.extra_disc1.id
  instance_id = aws_instance.whiskey1.id
}

# EXTRA DISCS #
resource "aws_ebs_volume" "extra_disc1" {
  availability_zone = var.az
  size              = 10
  type              = "gp2"
  encrypted         = true

  tags = {
    Name = "whiskey_disc1"
  }
}
# INSTANCES #
resource "aws_instance" "whiskey1" {
  ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.whiskey_subnet.id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  availability_zone      = var.az

  tags  = {
    Name = "whiskey1"
    Owner = "Grandpa"
    Purpose = "Whiskey"
  }

  user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
sudo rm /usr/share/nginx/html/index.html
echo '<html><head><title>Grandpas Whiskey</title></head><body>Welcome to Grandpa&apos;s Whiskey</body></html>' | sudo tee /usr/share/nginx/html/index.html
EOF
}
# Attach Disc
resource "aws_volume_attachment" "ebs_attach2" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.extra_disc2.id
  instance_id = aws_instance.whiskey2.id
}

# EXTRA DISCS #
resource "aws_ebs_volume" "extra_disc2" {
  availability_zone = var.az
  size              = 10
  type              = "gp2"
  encrypted         = true

  tags = {
    Name = "whiskey_disc2"
  }
}
# INSTANCES #
resource "aws_instance" "whiskey2" {
  ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.whiskey_subnet.id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  availability_zone      = var.az

  tags  = {
    Name = "whiskey2"
    Owner = "Grandpa"
    Purpose = "Whiskey"
  }

  user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
sudo rm /usr/share/nginx/html/index.html
echo '<html><head><title>Grandpas Whiskey</title></head><body>Welcome to Grandpa&apos;s Whiskey</body></html>' | sudo tee /usr/share/nginx/html/index.html
EOF
}
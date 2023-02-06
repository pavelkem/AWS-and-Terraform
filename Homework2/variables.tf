variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
	default = "10.20.0.0/16"
}

variable "subnets_cidr_public" {
	type = list(string)
	default = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "subnets_cidr_private" {
  type = list(string)
  default = ["10.20.3.0/24", "10.20.4.0/24"]
}

variable "azs" {
	type = list(string)
	default = ["us-east-1a", "us-east-1b"]
}

# ami-0bf0565838358789b 4.14
# ami-0aa7d40eeae50c9a9
variable "webservers_ami" {
  default = "ami-0aa7d40eeae50c9a9"
}

variable "dbservers_ami" {
  default = "ami-0aa7d40eeae50c9a9"
}

variable "instance_type" {
  default = "t2.micro"
}
# VPC
resource "aws_vpc" "terra_vpc" {
  cidr_block       = "${var.vpc_cidr}"
  tags = {
    Name = "TerraVPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "terra_igw" {
  vpc_id = "${aws_vpc.terra_vpc.id}"
  tags = {
    Name = "main"
  }
}

# Subnets : public
resource "aws_subnet" "wh_public_sn" {
  count = "${length(var.subnets_cidr_public)}"
  vpc_id = "${aws_vpc.terra_vpc.id}"
  cidr_block = "${element(var.subnets_cidr_public,count.index)}"
  availability_zone = "${element(var.azs,count.index)}"
  tags = {
    Name = "Subnet-public-${count.index+1}"
  }
}


# Subnets : private
resource "aws_subnet" "wh_private_sn" {
  count = "${length(var.subnets_cidr_private)}"
  vpc_id = "${aws_vpc.terra_vpc.id}"
  cidr_block = "${element(var.subnets_cidr_private,count.index)}"
  availability_zone = "${element(var.azs,count.index)}"
  tags = {
    Name = "Subnet-private-${count.index+1}"
  }
}

# Route table: attach Internet Gateway 
resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.terra_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.terra_igw.id}"
  }
  tags = {
    Name = "publicRouteTable"
  }
}

###################

# Allocate EIPs for the NATs
resource "aws_eip" "nat" {
  count  = "${length(var.subnets_cidr_private)}"
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

# Create NAT gateways
resource "aws_nat_gateway" "nat" {
  count = "${length(var.subnets_cidr_private)}"

  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.wh_public_sn.*.id, count.index)}"

  # to do remove warning: Quoted references are deprecated
  # Make sure it's brought up only once the igw and subnet are ready
  depends_on = ["aws_internet_gateway.terra_igw", "aws_subnet.wh_public_sn"]
  tags = {
    Name        = "NAT-gateway-${count.index+1}"
    Service     = "nat"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create private route tables
resource "aws_route_table" "private_rt" {
  count = "${length(var.subnets_cidr_private)}"

  vpc_id = "${aws_vpc.terra_vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.nat.*.id, count.index)}"
  }

  tags = {
    Name        = "Private-routetb-${count.index+1}"
    Service     = "nat"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Route table association with private subnets
resource "aws_route_table_association" "b" {
  count = "${length(var.subnets_cidr_private)}"
  subnet_id      = "${element(aws_subnet.wh_private_sn.*.id,count.index)}"
  route_table_id = "${element(aws_route_table.private_rt.*.id,count.index)}"
}
  
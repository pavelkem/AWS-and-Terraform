
resource "aws_instance" "webservers" {
  count = "${length(var.subnets_cidr_public)}" 
  ami = "${var.webservers_ami}"
  availability_zone = "${element(var.azs,count.index)}"
  instance_type = "${var.instance_type}"
  vpc_security_group_ids = ["${aws_security_group.webservers.id}"]
  subnet_id = "${element(aws_subnet.wh_public_sn.*.id,count.index)}"
  key_name      = "${aws_key_pair.VPC-demo-key.key_name}"
  associate_public_ip_address = true
  user_data = "${file("post_install.sh")}"
  
  tags = {
    Name = "Webserver-${count.index+1}"
  }
}

resource "aws_instance" "dbservers" {
  count = "${length(var.subnets_cidr_public)}" 
  ami = "${var.dbservers_ami}"
  availability_zone = "${element(var.azs,count.index)}"
  instance_type = "${var.instance_type}"
  vpc_security_group_ids = ["${aws_security_group.dbservers.id}"]
  subnet_id = "${element(aws_subnet.wh_private_sn.*.id,count.index)}"
  key_name      = "${aws_key_pair.VPC-demo-key.key_name}"

  tags = {
    Name = "Dbserver-${count.index+1}"
  }
}


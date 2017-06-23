resource "aws_vpc" "tools" {
  cidr_block  = "${var.vpc_cidr}"
  enable_dns_hostnames = true 
  tags {
    Name = "tools"
  }
}

resource "aws_internet_gateway" "tools" {
  vpc_id = "${aws_vpc.tools.id}"
}


#create private subnet

resource "aws_subnet" "eu-west-2a-private" {
  vpc_id  = "${aws_vpc.tools.id}"

  cidr_block = "${var.private1_subnet_cidr}"
  availability_zone = "eu-west-2a"

  tags {
    Name = "Primary Private Subnet"
  }
}

resource "aws_route_table" "eu-west-2a-private" {
  vpc_id = "${aws_vpc.tools.id}"

  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${aws_instance.nat.id}"
  }

  tags {
    Name = "Private Subnet"
  }
}

resource "aws_route_table_association" "eu-west-2a-private" {
  subnet_id = "${aws_subnet.eu-west-2a-private.id}"
  route_table_id = "${aws_route_table.eu-west-2a-private.id}"
}


#create public subnet

resource "aws_subnet" "eu-west-2a-public" {
  vpc_id = "${aws_vpc.tools.id}"

  cidr_block = "${var.public1_subnet_cidr}"
  availability_zone = "eu-west-2a"

  tags {
    Name = "Public Subnet"
  }
}


resource "aws_route_table" "eu-west-2a-public" {
  vpc_id = "${aws_vpc.tools.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.tools.id}"
  }

  tags {
    Name = "Public Subnet"
  }
}

#nat instance

resource "aws_instance" "nat" {
  ami = "ami-0a4c5a6e"
  availability_zone = "eu-west-2a"
  instance_type = "t2.nano"
  key_name = "${var.aws_key_name}"
  vpc_security_group_ids = ["${aws_security_group.nat.id}"]
  subnet_id = "${aws_subnet.eu-west-2a-public.id}"
  associate_public_ip_address = true
  source_dest_check = false

  tags {
    Name = "VPC NAT"
  }
}

resource "aws_security_group" "nat" {
  name = "vpc_nat"
  description = "Allows traffic from private subnet to internet"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.private1_subnet_cidr}"]
  }
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["${var.private1_subnet_cidr}"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.tools.id}"

  tags {
    Name = "NATSG"
  }
}


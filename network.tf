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

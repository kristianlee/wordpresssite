
resource "aws_vpc" "tools" {
  cidr_block  = "10.0.0.0/16"
  
  tags {
    Name = "tools"
  }
}

#resource "aws_subnet" "primary" {
#  vpc_id  = 

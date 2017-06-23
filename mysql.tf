resource "aws_instance" "mysql1" {
    ami = "ami-cc7066a8"
    instance_type = "t2.small"
    subnet_id = "${aws_subnet.eu-west-2a-private.id}"

    tags {
      Name = "mysql primary"
    }

    provisioner "local-exec" {
      command = "sleep 30 && echo -e \"[mysqlprimary]\n${aws_instance.mysql1.public_ip} ansible_connection=ssh ansible_ssh_user=ubuntu\" > inventory"
    }

}

output "ip" {
  value = "${aws_instance.mysql1.private_ip}"
}

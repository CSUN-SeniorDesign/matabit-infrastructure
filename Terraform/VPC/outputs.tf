# Outputs
output "vpc_id" {
  value = "${aws_vpc.default.id}"
}

output "aws_subnet_public_a_id" {
  value = "${aws_subnet.public-subnet-a.id}"
}

output "aws_subnet_public_b_id" {
  value = "${aws_subnet.public-subnet-b.id}"
}

output "aws_subnet_public_c_id" {
  value = "${aws_subnet.public-subnet-c.id}"
}

output "aws_subnet_private_a_id" {
  value = "${aws_subnet.private-subnet-a.id}"
}

output "aws_subnet_private_b_id" {
  value = "${aws_subnet.private-subnet-b.id}"
}

output "aws_subnet_private_c_id" {
  value = "${aws_subnet.private-subnet-c.id}"
}

output "aws_public_cidr_a" {
  value = "${aws_subnet.public-subnet-a.cidr_block}"
}

output "aws_public_cidr_b" {
  value = "${aws_subnet.public-subnet-b.cidr_block}"
}

output "aws_public_cidr_c" {
  value = "${aws_subnet.public-subnet-c.cidr_block}"
}

output "aws_private_cidr_a" {
  value = "${aws_subnet.private-subnet-a.cidr_block}"
}

output "aws_private_cidr_b" {
  value = "${aws_subnet.private-subnet-b.cidr_block}"
}

output "aws_private_cidr_c" {
  value = "${aws_subnet.private-subnet-c.cidr_block}"
}

output "aws_vpc_cidr" {
  value = "${var.vpc_cidr}"
}

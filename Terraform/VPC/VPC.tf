terraform {
  backend "s3" {
    bucket = "matabit-terraform-state-bucket"
    region = "us-west-2"
    key    = "VPC/terraform.tfstate"
  }
}

# Define AWS as our provider
provider "aws" {
  region = "${var.aws_region}"
}

# Define our VPC
resource "aws_vpc" "default" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "matabit-vpc"
  }
}

# Define the public subnet
resource "aws_subnet" "public-subnet-a" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.public_subnet_cidr_a}"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags {
    Name = "public-subnet-a"
  }
}

resource "aws_subnet" "public-subnet-b" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.public_subnet_cidr_b}"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2b"

  tags {
    Name = "public-subnet-b"
  }
}

resource "aws_subnet" "public-subnet-c" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.public_subnet_cidr_c}"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2c"

  tags {
    Name = "public-subnet-c"
  }
}

# Define the private subnet
resource "aws_subnet" "private-subnet-a" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${var.private_subnet_cidr_a}"
  availability_zone = "us-west-2a"

  tags {
    Name = "private-subnet-a"
  }
}

resource "aws_subnet" "private-subnet-b" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${var.private_subnet_cidr_b}"
  availability_zone = "us-west-2b"

  tags {
    Name = "private-subnet-b"
  }
}

resource "aws_subnet" "private-subnet-c" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${var.private_subnet_cidr_c}"
  availability_zone = "us-west-2c"

  tags {
    Name = "private-subnet-c"
  }
}

# Define NAT Instance SG
resource "aws_security_group" "nat" {
  name        = "vpc_nat"
  description = "Allow traffic to pass from the private subnet to the internet"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.private_subnet_cidr_a}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.private_subnet_cidr_a}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "NAT-SG"
  }
}

# Create NAT instance
resource "aws_instance" "nat" {
  ami                         = "ami-40d1f038"                     # this is a special ami preconfigured to do NAT
  availability_zone           = "us-west-2a"
  instance_type               = "t2.micro"
  key_name                    = "matabit"
  vpc_security_group_ids      = ["${aws_security_group.nat.id}"]
  subnet_id                   = "${aws_subnet.public-subnet-a.id}"
  associate_public_ip_address = true
  source_dest_check           = false
  user_data                   = "${file("../cloud-init.conf")}"

  tags {
    Name = "VPC-NAT"
  }
}

# Give NAT instance an EIP
resource "aws_eip" "nat" {
  instance = "${aws_instance.nat.id}"
  vpc      = true
}

# Add Route53 name to NAT instance
resource "aws_route53_record" "ssh" {
  zone_id = "${var.aws_route53_matabit_zone_id}"
  name    = "ssh"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.nat.public_ip}"]
}

# Define the internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "VPC IGW"
  }
}

# Define public route table
resource "aws_route_table" "public-rt" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "public-subnet-route-table"
  }
}

# Define private route table attached to NAT instance
resource "aws_route_table" "private-rt" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = "${aws_instance.nat.id}"
  }

  tags {
    Name = "private-subnet-route-table"
  }
}

# Assign the public subnet to public route
resource "aws_route_table_association" "public-rt-a" {
  subnet_id      = "${aws_subnet.public-subnet-a.id}"
  route_table_id = "${aws_route_table.public-rt.id}"
}

resource "aws_route_table_association" "public-rt-b" {
  subnet_id      = "${aws_subnet.public-subnet-b.id}"
  route_table_id = "${aws_route_table.public-rt.id}"
}

resource "aws_route_table_association" "public-rt-c" {
  subnet_id      = "${aws_subnet.public-subnet-c.id}"
  route_table_id = "${aws_route_table.public-rt.id}"
}

# Assign private subnet to private route table
resource "aws_route_table_association" "private-rt-a" {
  subnet_id      = "${aws_subnet.private-subnet-a.id}"
  route_table_id = "${aws_route_table.private-rt.id}"
}

resource "aws_route_table_association" "private-rt-b" {
  subnet_id      = "${aws_subnet.private-subnet-b.id}"
  route_table_id = "${aws_route_table.private-rt.id}"
}

resource "aws_route_table_association" "private-rt-c" {
  subnet_id      = "${aws_subnet.private-subnet-c.id}"
  route_table_id = "${aws_route_table.private-rt.id}"
}

terraform {
  backend "s3" {
    bucket = "matabit-terraform-state-bucket"
    region = "us-west-2"
    dynamodb_table = "matabit-terraform-statelock"
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


# Define public route table
resource "aws_route_table" "public-rt" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
  }

  tags {
    Name = "public-subnet-route-table"
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
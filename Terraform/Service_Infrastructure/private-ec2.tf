terraform {
    backend "s3" {
        bucket = "matabit-terraform-state-bucket"
        region = "us-west-2"
        dynamodb_table = "matabit-terraform-statelock"
        key = "Service_Infrastructure/private-ec2.tfstate"
    }
}

provider "aws" {
  region = "us-west-2"
}

# Define VPC Remote State 
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config {
    bucket = "matabit-terraform-state-bucket"
    region = "us-west-2"
    key = "VPC/terraform.tfstate"
    name = "VPC/terraform.tfstate"
  }
}

# Private Web Server 1
resource "aws_instance" "web" {
  ami = "ami-51537029"
  instance_type = "t2.micro"
  subnet_id = "${data.terraform_remote_state.vpc.aws_subnet_private_a_id}"
  vpc_security_group_ids = ["${aws_security_group.web_sg.id}"]
  availability_zone = "us-west-2a"
  user_data = "${file("../cloud-init.conf")}"
  tags {
    Name = "matabit-private-ec2"
  }
}

# Private Web Server 2
resource "aws_instance" "web2" {
  ami = "ami-51537029"
  instance_type = "t2.micro"
  subnet_id = "${data.terraform_remote_state.vpc.aws_subnet_private_b_id}"
  availability_zone = "us-west-2b"
  vpc_security_group_ids = ["${aws_security_group.web_sg.id}"]
  user_data = "${file("../cloud-init.conf")}"
  tags {
    Name = "matabit-private-ec2"
  }
}

# Security group
resource "aws_security_group" "web_sg" {
  name = "private_web_sg"
  description = "Allow all outbound; only SSH inbound"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${data.terraform_remote_state.vpc.nat_private_ip}/32"]
  }
  
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["${data.terraform_remote_state.vpc.aws_vpc_cidr}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "matabit-private-ec2-SG"
  }
}

output "aws_private_ec2_id" {
  value = "${aws_instance.web.id}"
}
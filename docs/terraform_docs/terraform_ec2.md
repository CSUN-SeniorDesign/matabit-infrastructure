# Terraform EC2

## AWS EC2 backend

```
terraform {
    backend "s3" {
        bucket = "matabit-terraform-state-bucket"
        region = "us-west-2"
        dynamodb_table = "matabit-terraform-statelock"
        key = "Service_Infrastructure/private-ec2.tfstate"
    }
}
```

Here we are defining the `bucket` in which we are storing our state and also the `dynamodb_table` that we are using to lock the state.
The `key` is basically initializing the tf.state file inside the bucket that the state is being stored in.



## Defining our AWS EC2 instances

```
# Private Web Server 1
resource "aws_instance" "web" {
  ami = "ami-51537029"
  instance_type = "t2.micro"
  subnet_id = "${data.terraform_remote_state.vpc.aws_subnet_private_a_id}"
  vpc_security_group_ids = ["${aws_security_group.web_sg.id}"]
  user_data = "${file("../cloud-init.conf")}"
  tags {
    Name = "matabit-private-ec2-1"
  }
}

# Private Web Server 2
resource "aws_instance" "web2" {
  ami = "ami-51537029"
  instance_type = "t2.micro"
  subnet_id = "${data.terraform_remote_state.vpc.aws_subnet_private_b_id}"
  vpc_security_group_ids = ["${aws_security_group.web_sg.id}"]
  user_data = "${file("../cloud-init.conf")}"
  tags {
    Name = "matabit-private-ec2-2"
  }
}
```

We are using `t2.micro` instances and the Ubuntu 16.04 (`ami-51537029`) AMI. Through a `terraform_remote_state` data source we can retrieve the subnets that the VPC has defined and associate them with our EC2 instances.

## Getting the VPC `terraform_remote_state`
```
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
```

## Security Groups

For our Security Group we have to be careful as to not to expose it too widely as it would be a security risk to allow all traffic in and out.

This our security group for our private EC2 instances:


```
# Security group
resource "aws_security_group" "web_sg" {
  name = "private_web_sg"
  description = "Allow all outbound; only SSH inbound"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

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

  ingress {
    from_port = 80
    to_port = 80
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
```

We are enabling SSH from the NAT that is defined inside the public subnet of the VPC and enable all HTTP/HTTPS traffic coming from inside the VPC. Because the load balancer is supposed to forward the traffic to the private subnet.

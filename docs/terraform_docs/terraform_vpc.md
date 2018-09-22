# How to create VPC with an SSH/NAT Bastion
Requirements:

* IAM account with API/Programming access
* Terraform installed
* AWS-cli configured

## File structure
We will be creating the VPC in a separate folder container 3 main files: `VPC.tf`, `variables.tf`, and `outputs.tf`. The `VPC.tf` file will contain the resource blocks for the VPC. The `variables.tf` file will contain variable that will be hard-coded such as CIDR blocks. We will reference variables into our `VPC.tf` file. The `outputs.tf` file is important as it allows other Terraform scripts to read the VPC's state file to grab variables out of it.

## Variables 
Let's begin by setting some variables, this are items that will not typically changed while creating the VPC but will be reference multiple times. Instead of hard-coding let's say CIDR block multiple times, you can define it as a variable and reference it without worrying about copying/pasting a value. Here's how the code looks like:

This block states our AWS region 
```Terraform
variable "aws_region" {
  description = "Main Matabit VPC"
  default     = "us-west-2"
}
```

This will be the CIDR block assigned to our VPC
```Terraform
variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default     = "172.31.0.0/16"
}
``` 

Here's an example of private and public subnets. For this project we create 3 of each.
```Terraform
variable "public_subnet_cidr_a" {
  description = "CIDR for the public subnet-a"
  default     = "172.31.2.0/22"
}

variable "private_subnet_cidr_a" {
  description = "CIDR for the private subnet-a"
  default     = "172.31.16.0/20"
}

```

## Resource file `VPC.tf`
This file will contain the resource blocks for our infrastructure. Resource blocks are small piece for the AWS console that you can physically click in order to make. Terraform is infrastructure as code, so instead of tediously clicking through the AWS console you can deploy infrastructure in seconds.

First, we must use an S3 backend to keep track of our state file remotely. The state file contains all the assets associated with the Terraform code. Keeping a record remotely allows use to reference resources and allow use to lock the file to prevent more than one person from running the terraform code.
```Terraform
terraform {
  backend "s3" {
    bucket = "matabit-terraform-state-bucket"
    region = "us-west-2"
    key    = "VPC/terraform.tfstate"
  }
}
```
 Next is to specify the region we want our AWS infrastructure to deploy in notice how we used a variable from the `variables.tf` file.
```Terraform
provider "aws" {
  region = "${var.aws_region}"
}
```
Now to define the VPC and its networks(Private and Public subnets). We have 3 public and private subnets spread into the 3 us-west-2 regions a,b,c respectively. A sample below
```Terraform
resource "aws_vpc" "default" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "matabit-vpc"
  }
}

resource "aws_subnet" "public-subnet-a" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.public_subnet_cidr_a}"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags {
    Name = "public-subnet-a"
  }
}

resource "aws_subnet" "private-subnet-a" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${var.private_subnet_cidr_a}"
  availability_zone = "us-west-2a"

  tags {
    Name = "private-subnet-a"
  }
}
```

Now we will our internet gateway along with defining route tables and associating the subnets with their respective route tables. Anything in the public subnet will be allowed to have network access to the world. The private subnets we be isolated until they a NAT/Bastion set up. We also included cloud-init to provision the Bastion to add our SSH keys and set up our user accounts. 
```Terraform
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

resource "aws_route_table_association" "private-rt-a" {
  subnet_id      = "${aws_subnet.private-subnet-a.id}"
  route_table_id = "${aws_route_table.private-rt.id}"
}

```
The NAT will also be used as an SSH bastion. It will be placed on the public subnet and allows the private subnet access to a few things such as SSH, HTTP, and HTTPS. The private subnet route to the NAT which allows it to gain access the outside world, with restrictions from the Security group. The NAT bastion will be a EC2 instance.
```Terraform
resource "aws_security_group" "nat" {
  name        = "vpc_nat"
  description = "Allow traffic to pass from the private subnet to the internet"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
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
```

## The outputs.tf file
The `outputs.tf` will take variables from specific resources and output those values so other Terraform files can reference them. This is useful for our Service Infrastructure as some of the resource requires some variable such as subnet and zones. Here's a sample of a few outputs.
```Terraform
output "vpc_id" {
  value = "${aws_vpc.default.id}"
}

output "nat_sg_id" {
  value = "${aws_security_group.nat.id}"
}
```


### Running the script
To run the scipt first plan to test out the syntax `terraform plan`. If everything is good apply the code using `terraform apply`.
# How to create VPC with an SSH/NAT Bastion
Requirements:

* IAM account with API/Programming access
* Terraform installed
* AWS-cli configured

## File structure
We will be creating the VPC in a seperate folder container 3 main files: `VPC.tf`, `variables.tf`, and `outputs.tf`. The `VPC.tf` file will contain the resource blocks for the VPC. The `variables.tf` file will contain varable that will be hard-coded such as CIDR blocks. We will reference variables into our `VPC.tf` file. The `outputs.tf` file is important as it allows other Terraform scripts to read the VPC's statefile to grab variables out of it.

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

Here's an example of private dn public subnets. For this project we create 3 of each.
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

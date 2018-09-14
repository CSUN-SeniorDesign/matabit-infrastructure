variable "aws_region" {
  description = "Main Matabit VPC"
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default     = "172.31.0.0/16"
}

variable "public_subnet_cidr_a" {
  description = "CIDR for the public subnet-a"
  default     = "172.31.2.0/22"
}

variable "public_subnet_cidr_b" {
  description = "CIDR for the public subnet-b"
  default     = "172.31.4.0/22"
}

variable "public_subnet_cidr_c" {
  description = "CIDR for the public subnet-c"
  default     = "172.31.8.0/22"
}

variable "private_subnet_cidr_a" {
  description = "CIDR for the private subnet-a"
  default     = "172.31.16.0/20"
}

variable "private_subnet_cidr_b" {
  description = "CIDR for the private subnet-b"
  default     = "172.31.32.0/20"
}

variable "private_subnet_cidr_c" {
  description = "CIDR for the private subnet-c"
  default     = "172.31.48.0/20"
}

variable "aws_route53_matabit_zone_id" {
  description = "Hosted zone ID for Matabit"
  default     = "Z1CSZ4RFCJ1SAK"
}

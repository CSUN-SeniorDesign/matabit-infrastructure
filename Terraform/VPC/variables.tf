variable "aws_region" {
  description = "Main VPC"
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default     = "132.124.0.0/18"
}

variable "public_subnet_cidr_a" {
  description = "CIDR for the public subnet-a"
  default     = "132.124.2.0/22"
}

variable "public_subnet_cidr_b" {
  description = "CIDR for the public subnet-b"
  default     = "132.124.4.0/22"
}

variable "public_subnet_cidr_c" {
  description = "CIDR for the public subnet-c"
  default     = "132.124.8.0/22"
}

variable "private_subnet_cidr_a" {
  description = "CIDR for the private subnet-a"
  default     = "132.124.16.0/20"
}

variable "private_subnet_cidr_b" {
  description = "CIDR for the private subnet-b"
  default     = "132.124.32.0/20"
}

variable "private_subnet_cidr_c" {
  description = "CIDR for the private subnet-c"
  default     = "132.124.48.0/20"
}

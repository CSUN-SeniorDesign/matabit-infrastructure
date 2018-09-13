terraform {
    backend "s3" {
        bucket = "matabit-terraform-state-bucket"
        region = "us-west-2"
        dynamodb_table = "matabit-terraform-statelock"
        key = "Service_Infrastructure/terraform.tfstate"
    }
}

# data "terraform_remote_state" "vpc" {
#   backend = "s3"
#   config {
#     bucket = "matabit-terraform-state-bucket"
#     region = "us-west-2"
#     name = "VPC/terrafrom.tfstate"
#   }
# }

provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "web" {
  ami = "ami-51537029"
  instance_type = "t2.micro"
  subnet_id = "subnet-09f27f7bb7b7c6bd4"
  user_data = "${file("cloud-init.conf")}"
  tags {
    Name = "matabit-private-ec2"
  }
}

# data "aws_route53_zone" "selected" {
#   name         = "matabit.org."
#   private_zone = true
# }

# resource "aws_route53_record" "www" {
#   zone_id = "${data.aws_route53_zone.selected.zone_id}"
#   name    = "www.${data.aws_route53_zone.selected.name}"
#   type    = "A"
#   ttl     = "300"
#   records = [""]
# }


# resource "aws_route53_record" "blog" {
#   zone_id = "${data.aws_route53_zone.selected.zone_id}"
#   name    = "blog.${data.aws_route53_zone.selected.name}"
#   type    = "A"
#   ttl     = "300"
#   records = [""]
# }

# resource "aws_route53_record" "apex" {
#   zone_id = "${data.aws_route53_zone.selected.zone_id}"
#   name    = "${data.aws_route53_zone.selected.name}"
#   type    = "A"
#   ttl     = "300"
#   records = [""]
# }



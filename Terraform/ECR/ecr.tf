terraform {
  backend "s3" {
    bucket         = "matabit-terraform-state-bucket"
    region         = "us-west-2"
    dynamodb_table = "matabit-terraform-statelock"
    key            = "ecr/s3.tfstate"
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_ecr_repository" "matabit-ecr" {
  name = "matabit-ecr"
}

output "ecr_arn" {
  value = "${aws_ecr_repository.matabit-ecr.arn}"
}

output "ecr_name" {
  value = "${aws_ecr_repository.matabit-ecr.name}"
}

output "ecr_registry_id" {
  value = "${aws_ecr_repository.matabit-ecr.registry_id}"
}

output "ecr_repo_url" {
  value = "${aws_ecr_repository.matabit-ecr.repository_url}"
}

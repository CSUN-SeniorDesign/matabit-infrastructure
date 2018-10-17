terraform {
  backend "s3" {
    bucket = "matabit-terraform-state-bucket"
    region = "us-west-2"
    key    = "Lambda/lambda.tfstate"
  }
}

# Define AWS as our provider
provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_s3_bucket_notification" "s3-bucket-notification" {
  bucket = ""
}


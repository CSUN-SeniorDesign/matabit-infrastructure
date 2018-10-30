terraform {
  backend "s3" {
    bucket         = "matabit-terraform-state-bucket"
    region         = "us-west-2"
    dynamodb_table = "matabit-terraform-statelock"
    key            = "S3/s3.tfstate"
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "matabit-circleci" {
  bucket = "matabit-circleci"
  acl    = "public-read"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement":[{
  	"Sid": "AddPerm",
  	"Effect": "Allow",
  	"Principal": "*",
  	"Action": ["s3:GetObject"],
  	"Resource": ["arn:aws:s3:::matabit-circleci/*"]
  }]
}
 POLICY

  versioning {
    enabled = true
  }

  tags {
    Name        = "matabit-circleci"
    Environment = "Dev"
  }

  website {
    index_document = "index.html"
    error_document = "404.html"
  }
}
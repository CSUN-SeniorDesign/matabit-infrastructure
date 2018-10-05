# Creating an S3 bucket with Terraform
Create an S3 bucket with Terraform is extremely simple.

## Example
I this example we made sure to save the state-file in another S3 bucket. The next block set the AWS region. The last resource block create the S3 bucket with its associated tags.
```json
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
  acl    = "private"

  versioning {
    enabled = true
  }

  tags {
    Name        = "matabit-circleci"
    Environment = "Dev"
  }
}

```
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

## Project 5

For project 5 we had to implent the cheapest way to host our blog site  
For the S3 bucket all we had to change was the acl from private to public and add a policy to allow the viewers to view the content of the site. 

Our current S3 bucket looks as so: 

```
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

resource "aws_s3_bucket" "matabit" {
  bucket = "matabit.org"
  acl    = "public-read"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement":[{
  	"Sid": "AddPerm",
  	"Effect": "Allow",
  	"Principal": "*",
  	"Action": ["s3:GetObject"],
  	"Resource": ["arn:aws:s3:::matabit.org/*"]
  }]
}
 POLICY

  versioning {
    enabled = true
  }

  website {
    index_document = "index.html"
    error_document = "404.html"
  }
}
```
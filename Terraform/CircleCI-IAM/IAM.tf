terraform {
  backend "s3" {
    bucket         = "matabit-terraform-state-bucket"
    region         = "us-west-2"
    dynamodb_table = "matabit-terraform-statelock"
    key            = "circle-ci-iam/s3.tfstate"
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_iam_group" "circleci" {
  name = "circleci"
}

# resource "aws_iam_access_key" "circleci" {
#   user = "${aws_iam_user.circleci.name}"
#   pgp_key = "keybase:matabit-circleci"
# }

resource "aws_iam_group" "ec2-get-s3" {
  name = "ec2-get-s3"
}

resource "aws_iam_group_policy" "circle-ci-put" {
  name  = "circle-ci-put"
  group = "${aws_iam_group.circleci.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:PutObject",
            "Resource": [
                "arn:aws:s3:::matabit-circleci"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_user" "circleci" {
  name = "circleci"
}

resource "aws_iam_group_membership" "circleci" {
  name = "cirleci"

  users = [
    "${aws_iam_user.circleci.id}",
  ]

  group = "${aws_iam_group.circleci.name}"
}

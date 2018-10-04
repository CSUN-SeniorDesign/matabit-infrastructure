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

/* Circle CI User/Group */
resource "aws_iam_user" "circleci" {
  name = "circleci"
}

resource "aws_iam_group" "circleci" {
  name = "circleci"
}

resource "aws_iam_group_membership" "circleci" {
  name  = "cirleci"
  users = ["${aws_iam_user.circleci.id}"]
  group = "${aws_iam_group.circleci.name}"
}

/* IAM Policies */
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
              "arn:aws:s3:::*/*",
              "arn:aws:s3:::matabit-circleci"
              ]
        }
    ]
}
EOF
}

/* EC-2 GET IAM*/
resource "aws_iam_role" "ec2-get" {
  name = "ec2-get-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
  EOF
}

resource "aws_iam_instance_profile" "ec2-get" {
  name = "ec2-get-profile"
  role = "${aws_iam_role.ec2-get.name}"
}

resource "aws_iam_role_policy" "ec2-get" {
  name = "ec2-get-role-policy"
  role = "${aws_iam_role.ec2-get.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::*/*",
                "arn:aws:s3:::matabit-circleci"
            ]
        }
    ]
}
  EOF
}

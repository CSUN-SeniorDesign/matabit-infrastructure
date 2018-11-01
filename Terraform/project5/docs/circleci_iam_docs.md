# Creating IAM user for CircleCI

Creating our IAM user for CircleCI was pretty simple considering most of what we needed was already there from previous projects. 

The terraform file will create an IAM user account for CircleCI and assign it to a group. It creates a policy for that group which has permissions to put and delete objects from an S3 bucket. One of the S3 buckets specified for these actions is our matabit.org bucket which will be storing our website contents. This policy will allow CircleCI to push new contents into the bucket whenever it is manually approved to do so.

```
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
  name  = "circleci"
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
            "Action": [
              "s3:PutObject",
              "s3:DeleteObject",
              "s3:ListBucket"
            ],
            "Resource": [
              "arn:aws:s3:::*/*",
              "arn:aws:s3:::matabit.org",
              "arn:aws:s3:::matabit.org/*"
              ]
        }
    ]
}
EOF
}
```
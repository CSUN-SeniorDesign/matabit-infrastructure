# AWS IAM Setup

## Setting up Terraform for IAM

Setting up the Terraform file for IAM, ensure that a S3 Bucket backend is chosen as well as a DynamoDB table to ensure State locking, so that only one person at a time can work on a terraform state!

```json
terraform {
    backend "s3" {
        bucket = "matabit-terraform-state-bucket"
        region = "us-west-2"
        dynamodb_table = "matabit-terraform-statelock"
        key = "IAM/terraform.tfstate"
    }
}
```
Also ensure that the region for the provider 'aws' is set to "us-west-2", otherwise resources are going to be built-in different regions.

## Password Policy

It is suggested to set up a password policy for all the IAM users. This enhances security.

```json
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 6
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = false
  require_symbols                = true
  allow_users_to_change_password = true
}

```

## Group Policy

An IAM group has to be created and in addition to that a group policy has to be attached.
For now we are enabling all the IAM users to have full administrator access, that way all the users can experiment and work on all the resources that they need to.


```json
resource "aws_iam_group" "matabit-admins" {
    name = "matabit-admins"
}


resource "aws_iam_group_policy_attachment" "attach-admin-access" {
    group = "${aws_iam_group.matabit-admins.id}"
    policy_arn  = "arn:aws:iam::aws:policy/AdministratorAccess"
}
```


## Create users and define memberships

Create users like such: 
```json
resource "aws_iam_user" "thomas" {
    name = "thomas"
}

resource "aws_iam_user" "shahed" {
    name = "shahed"
}

resource "aws_iam_user" "anthony" {
    name = "anthony"
}

resource "aws_iam_user" "mario" {
    name = "mario"
}
```

And attach them to the earlier created group:

```
resource "aws_iam_group_membership" "matabit" {
    name = "matabit-team-membership"
    users = [
      "${aws_iam_user.anthony.id}",
      "${aws_iam_user.mario.id}",
      "${aws_iam_user.thomas.id}",
      "${aws_iam_user.shahed.id}"
    ]
    group = "${aws_iam_group.matabit-admins.name}"
}
```
## Giving default passwords
Log into the AWS Management console and give each IAM user a default password that they have to change upon the first login.
This ensures that everyone can chose the login that they need.

## Access Key/Secret

For users to efficiently create their Terraform resoruces, they need Access Keys and Secrets. The users have to log in with their user name into the Management console and create their Access Keys and Secrets in the IAM Service. This way they are not transmitted in unsecured ways.

## Creating a Role policy
A role policy is useful for aligning permissions based off an instance instead of users. It follows the same methods as the group policies, except it differs in the resource blocks (using roles). We create an IAM role, then an instance profile which is then attached to a role policy

```json
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

```
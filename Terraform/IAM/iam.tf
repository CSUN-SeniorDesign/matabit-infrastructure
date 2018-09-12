terraform {
    backend "s3" {
        bucket = "matabit-terraform-state-bucket"
        region = "us-west-2"
        dynamodb_table = "matabit-terraform-statelock"
        key = "IAM/terraform.tfstate"
    }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 6
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = false
  require_symbols                = true
  allow_users_to_change_password = true
}

resource "aws_iam_group" "matabit-admins" {
    name = "matabit-admins"
}

resource "aws_iam_group_policy_attachment" "attach-admin-access" {
    group = "${aws_iam_group.matabit-admins.id}"
    policy_arn  = "arn:aws:iam::aws:policy/AdministratorAccess"
}

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




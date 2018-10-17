resource "aws_iam_role" "lambda-ecs-role" {
  name = "lambda-ecs-role"

  assume_role_policy = <<EOF
    {
    "Version": "2012-10-17",
    "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
   ]
  }
  EOF
}

resource "aws_iam_policy" "lambda-ecs-policy" {
  name        = "lambda-ecs-policy"
  path        = "/"
  description = "IAM policy for Lambda to update ECS and read S3"

  policy = <<EOF
  {
      "Version" : "2012-10-17"
      "Statement": [
          {
              "Effect" : "Allow",
              "Action" : [
                  "s3:*"
                  "cloudwatch:*",
                  "logs:*",
                  "lambda:*",
                  "ecs:*",
                  "ecr:*",
                  "events:*"
              ],
              "Resouce":"*"
          }
      ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "lambda-ecs-attach" {
  role = "${aws_iam_role.lambda-ecs-role.name}"
  policy_arn = "${aws_iam_policy.lambda-ecs-policy.arn}"
}
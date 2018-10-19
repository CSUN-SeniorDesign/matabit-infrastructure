# How to create a Lambda Function with Terraform

## What is a Lambda Function
AWS Lambda lets you run code without provisioning or managing servers. You pay only for the compute time you consume - there is no charge when your code is not running.

## Getting started
Make sure you have the AWS-CLI and Terraform installed. Also make sure you configure your AWS-CLI with the proper API keys. Zip up the Lambda script you wish to deploy.

## Create an IAM Role for Lambda
We must first create an IAM Role and attach a policy. The policy will allow the Lambda function to use certain resources as it runs. The sample code below will create a IAM role, then policy, then attached the policy to the role
```
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
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "logs:*",
        "cloudwatch:*",
        "ecs:*",
        "ecr:*",
        "lambda:*",
        "iam:PassRole",
        "events:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda-ecs-attach" {
  role       = "${aws_iam_role.lambda-ecs-role.name}"
  policy_arn = "${aws_iam_policy.lambda-ecs-policy.arn}"
}

```

## Lambda Function block
The Lambda function resource block will specify the actual script to run. You would need to zip up your scripts beforehand. Specify the filename as a zip. Also give it a function name. We then attached the role created about to this Lambda function. The handler should be the name of the script, in this case it will be `update-ecs-staging.py` will be `update-ecs-staging`. We all add the name of the main function in the handler after the name, which is why the handle is `update-ecs-staging.main`. The source hash is the zip file and the runtime is the language of the Lambda function. 
```
resource "aws_lambda_function" "update-service-lambda-staging" {
  filename         = "lambda-staging.zip"
  function_name    = "update-ecs-service-staging"
  role             = "${aws_iam_role.lambda-ecs-role.arn}"
  handler          = "update-ecs-staging.main"
  source_code_hash = "${base64sha256(file("lambda-staging.zip"))}"
  runtime          = "python3.6"
}
```

## Allow Lambda to access S3
For our trigger we need to give Lambda access to an S3 bucket
```
resource "aws_lambda_permission" "allow_bucket-prod" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.update-service-lambda-prod.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${var.circle-ci-bucket-arn}"
}
```

## Creating a trigger
To create an S3 trigger, we need to use the s3_bucket_notification resource block. We need to specify the bucket and the Lambda Function it need to trigger. Inside the lambda_function block, we can specify the events to listen on 

```
resource "aws_s3_bucket_notification" "s3-bucket-notification" {
  bucket = "${var.circle-ci-bucket-id}"
  lambda_function{
    lambda_function_arn = "${aws_lambda_function.update-service-lambda-prod.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "docker-prod/"
    filter_suffix       = ".txt"
  }
```


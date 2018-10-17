terraform {
  backend "s3" {
    bucket = "matabit-terraform-state-bucket"
    region = "us-west-2"
    key    = "Lambda/lambda.tfstate"
  }
}

# Define AWS as our provider
provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_lambda_function" "update-service-lambda-staging" {
  filename         = "lambda-staging.zip"
  function_name    = "update-ecs-service-staging"
  role             = "${aws_iam_role.lambda-ecs-role.arn}"
  handler          = "update-ecs-staging.main"
  source_code_hash = "${base64sha256(file("lambda-staging.zip"))}"
  runtime          = "python3.6"
}

resource "aws_lambda_function" "update-service-lambda-prod" {
  filename         = "lambda-prod.zip"
  function_name    = "update-ecs-service-prod"
  role             = "${aws_iam_role.lambda-ecs-role.arn}"
  handler          = "update-ecs-prod.main"
  source_code_hash = "${base64sha256(file("lambda-prod.zip"))}"
  runtime          = "python3.6"
}
resource "aws_lambda_permission" "allow_bucket-prod" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.update-service-lambda-prod.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${var.circle-ci-bucket-arn}"
}

resource "aws_lambda_permission" "allow_bucket-staging" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.update-service-lambda-staging.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${var.circle-ci-bucket-arn}"
}

resource "aws_s3_bucket_notification" "s3-bucket-notification" {
  bucket = "${var.circle-ci-bucket-id}"
  lambda_function{
    lambda_function_arn = "${aws_lambda_function.update-service-lambda-prod.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "docker-prod/"
    filter_suffix       = ".txt"
  }

  lambda_function{
    lambda_function_arn = "${aws_lambda_function.update-service-lambda-staging.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "docker-staging/"
    filter_suffix       = ".txt"
  }
}

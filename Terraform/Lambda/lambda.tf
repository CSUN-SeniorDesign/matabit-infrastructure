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

resource "aws_lambda_function" "update-service-lambda" {
  filename         = "wow.zip"
  function_name    = "update-ecs-service"
  role             = "${aws_iam_role.lambda-ecs-role.arn}"
  handler          = "update-ecs.main"
  source_code_hash = "${base64sha256(file("wow.zip"))}"
  runtime          = "python3.6"
}
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.update-service-lambda.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${var.circle-ci-bucket-arn}"
}

resource "aws_s3_bucket_notification" "s3-bucket-notification" {
  bucket = "${var.circle-ci-bucket-id}"
  lambda_function{
    lambda_function_arn = "${aws_lambda_function.update-service-lambda.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".txt"
  }
}
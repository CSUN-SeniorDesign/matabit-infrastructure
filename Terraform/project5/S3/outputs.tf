output "matabit-circle-ci-bucket-id" {
  value = "${aws_s3_bucket.matabit.id}"
}

output "matabit-circle-ci-bucket-arn" {
  value = "${aws_s3_bucket.matabit.arn}"
}

output "matabit-web-endpoint" {
  value = "${aws_s3_bucket.matabit.website_endpoint}"
}

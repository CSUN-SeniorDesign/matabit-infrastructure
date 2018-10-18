output "matabit-circle-ci-bucket-id" {
  value = "${aws_s3_bucket.matabit-circleci.id}"
}

output "matabit-circle-ci-bucket-arn" {
  value = "${aws_s3_bucket.matabit-circleci.arn}"
}

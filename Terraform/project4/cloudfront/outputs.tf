output "cloudfront-domain" {
  value = "${aws_cloudfront_distribution.matabit_distribution.domain_name}"
}

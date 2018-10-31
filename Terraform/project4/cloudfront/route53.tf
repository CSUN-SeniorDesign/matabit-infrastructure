

resource "aws_route53_zone" "zone" {
  name = "matabit.org"
}

resource "aws_route53_record" "apex" {
  zone_id = "${aws_route53_zone.zone.zone_id}"
  name    = "matabit.org"
  type    = "A"

  alias = {
    name                   = "${aws_cloudfront_distribution.matabit_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.matabit_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.zone.zone_id}"
  name    = "www.matabit.org"
  type    = "A"

  alias = {
    name                   = "${aws_cloudfront_distribution.matabit_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.matabit_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "blog" {
  zone_id = "${aws_route53_zone.zone.zone_id}"
  name    = "blog.matabit.org"
  type    = "A"

  alias = {
    name                   = "${aws_cloudfront_distribution.matabit_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.matabit_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}
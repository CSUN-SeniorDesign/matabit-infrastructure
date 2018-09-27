data "aws_route53_zone" "selected" {
  name         = "matabit.org."
  private_zone = false
}

resource "aws_route53_record" "alb-record-www" {
  zone_id = "${data.aws_route53_zone.selected.id}" # Replace with your zone ID
  name    = "www.matabit.org." # Replace with your name/domain/subdomain
  type    = "A"

  alias {
    name = "${aws_lb.alb.dns_name}"
    zone_id = "${aws_lb.alb.zone_id}"
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "alb-record-blog" {
  zone_id = "${data.aws_route53_zone.selected.id}" # Replace with your zone ID
  name    = "blog.matabit.org." # Replace with your name/domain/subdomain
  type    = "A"
  alias {
    name = "${aws_lb.alb.dns_name}"
    zone_id = "${aws_lb.alb.zone_id}"
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "alb-record-apex" {
  zone_id = "${data.aws_route53_zone.selected.id}" # Replace with your zone ID
  name    = "matabit.org." # Replace with your name/domain/subdomain
  type    = "A"
  alias {
    name = "${aws_lb.alb.dns_name}"
    zone_id = "${aws_lb.alb.zone_id}"
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "alb-record-www-staging" {
  zone_id = "${data.aws_route53_zone.selected.id}" # Replace with your zone ID
  name    = "www.staging.matabit.org." # Replace with your name/domain/subdomain
  type    = "A"

  alias {
    name = "${aws_lb.alb.dns_name}"
    zone_id = "${aws_lb.alb.zone_id}"
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "alb-record-blog-staging" {
  zone_id = "${data.aws_route53_zone.selected.id}" # Replace with your zone ID
  name    = "blog.staging.matabit.org." # Replace with your name/domain/subdomain
  type    = "A"
  alias {
    name = "${aws_lb.alb.dns_name}"
    zone_id = "${aws_lb.alb.zone_id}"
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "alb-record-apex-staging" {
  zone_id = "${data.aws_route53_zone.selected.id}" # Replace with your zone ID
  name    = "staging.matabit.org." # Replace with your name/domain/subdomain
  type    = "A"
  alias {
    name = "${aws_lb.alb.dns_name}"
    zone_id = "${aws_lb.alb.zone_id}"
    evaluate_target_health = true
  }
}

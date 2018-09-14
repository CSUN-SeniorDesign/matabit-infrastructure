data "aws_route53_zone" "selected" {
  name         = "matabit.org."
  private_zone = false
}

# resource "aws_route53_record" "www" {
#   zone_id = "${data.aws_route53_zone.selected.zone_id}"
#   name    = "www.${data.aws_route53_zone.selected.name}"
#   type    = "A"
#   ttl     = "300"
#   records = [""]
# }


# resource "aws_route53_record" "blog" {
#   zone_id = "${data.aws_route53_zone.selected.zone_id}"
#   name    = "blog.${data.aws_route53_zone.selected.name}"
#   type    = "A"
#   ttl     = "300"
#   records = [""]
# }

# resource "aws_route53_record" "apex" {
#   zone_id = "${data.aws_route53_zone.selected.zone_id}"
#   name    = "${data.aws_route53_zone.selected.name}"
#   type    = "A"
#   ttl     = "300"
#   records = [""]
# }



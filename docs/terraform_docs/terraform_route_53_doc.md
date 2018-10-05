
# Terraform Route 53

## Hosted Zone

The following text provides details about a specific Route 53 Hosted Zone, which in this case is our website Matabit.org. The data source allows to find a Hosted Zone ID given a Hosted Zone and certain search criteria. It also shows how to get the Hosted Zone from its name and from this data how to create several record sets. 


## Data Source
```
data "aws_route53_zone" "selected" {
  name         = "matabit.org."
  private_zone = false
}
```

This block allows us to retrieve all the record sets and hosted zone information from the current Route53 setup.


## Resource Records

The following terraform resource block is for our route53 record sets which create Aliases for our Application Load Balancers's public DNS. The alias records let us route traffic to selected AWS resources, such as our Application Load Balancer. This also lets us route traffic from one record in a hosted zone to another record. 

Here is our Application Load Balancer Records for Route 53:

```
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
```

In addition, we have staging routes

```
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
```



Since Application Load Balancers cannot have Elastic IPs assigned to them we have to create Alias records that point to their DNS name.
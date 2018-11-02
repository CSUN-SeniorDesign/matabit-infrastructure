# Creating Cloudfront
To create the Cloudfront service to serve the site we need to depend on two resources beforehand: a publicly open S3 bucket and the ACM cert created in `us-east-1`. This is were we pull the two remote state files. Next we need to specify the `aws_cloudfront_distribution` resource block. There quite a few lines of code here. 
- The origin block specifics where to get the content from, in this case it will be the S3 bucket. We also state the ports 80 and 443. We also put http only because the S3 bucket is running on port 80 and not 443. This is where the ACM comes in
- The cache behavior states how long until the CDN is redistributed amongst it nodes. We set the default values here. We also redirect http to https on the Cloudfront side so our site is always running on 443.
- The Alias allow us to use sub domains from Route53's A records
- The resource restriction is set to none because we want to distribute the content on all nodes
- The viewer certification attached our ACM cert to our Cloudfront CDN
```json
terraform {
  backend "s3" {
    bucket         = "matabit-terraform-state-bucket"
    region         = "us-west-2"
    dynamodb_table = "matabit-terraform-statelock"
    key            = "cloudfront/state.tfstate"
  }
}

provider "aws" {
  region = "us-west-2"
}

data "terraform_remote_state" "s3" {
  backend = "s3"

  config {
    bucket = "matabit-terraform-state-bucket"
    region = "us-west-2"
    key    = "S3/s3.tfstate"
    name   = "S3/s3.tfstate"
  }
}

data "terraform_remote_state" "cert" {
  backend = "s3"
  config {
    bucket = "matabit-terraform-state-bucket"
    region = "us-west-2"
    key    = "acm/state.tfstate"
    name   = "acm/state.tfstate"
  }
}

resource "aws_cloudfront_distribution" "matabit_distribution" {
  origin {
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    domain_name = "${data.terraform_remote_state.s3.matabit-web-endpoint}"
    origin_id   = "matabit.org"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "matabit.org"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31546000

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  aliases = ["matabit.org","www.matabit.org","blog.matabit.org"]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${data.terraform_remote_state.cert.cert-arn}"
    ssl_support_method  = "sni-only"
  }
}
```

## Route53
I also created the Route 53 A records to point to Cloudfront's domain. The zone is default and the record reflects the subdomains(or Apex).

```json
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
```

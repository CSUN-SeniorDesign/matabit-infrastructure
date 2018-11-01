# AWS Certificate Manager

Setting up ACM with Terraform is pretty straight forward.

```
provider "aws" {
  region = "us-east-1"
}

resource "aws_acm_certificate" "matabit-cert" {
  domain_name       = "matabit.org"
  validation_method = "EMAIL"

  subject_alternative_names = ["*.matabit.org"]
}
```

Note the provider region! It is very important to designate `us-east-1` as the region as it is the only supported region for AWS CloudFront.

To quote AWS: 

`ACM Certificates in this region that are associated with a CloudFront distribution are distributed to all the geographic locations configured for that distribution.`

[Source](https://docs.aws.amazon.com/acm/latest/userguide/acm-regions.html)
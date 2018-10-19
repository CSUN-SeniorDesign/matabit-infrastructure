# ALB Terraform

## AWS Terraform Backend
```
terraform {
    backend "s3" {
        bucket = "matabit-terraform-state-bucket"
        region = "us-west-2"
        dynamodb_table = "matabit-terraform-statelock"
        key = "ALB/terraform.tfstate"
    }
}
```
The previous code is implemented into the terraform file to ensure that it is being stored in our backend s3 bucket.


## AWS Certificate
The following lines are used to obtain the ARN of a certificate within ACM and can be referenced by our domain name:
```
data "aws_acm_certificate" "matabit" {
    domain = "matabit.org"
    types = ["AMAZON_ISSUED"]
    most_recent = true
}
```

## ALB Definition
```
resource "aws_lb" "alb" {
    name = "aws-lb"
    internal = false
    load_balancer_type = "application"
    security_groups = ["${aws_security_group.security-lb.id}"]
    idle_timeout = "60"
    enable_cross_zone_load_balancing = true
    enable_deletion_protection = false
    subnets = [
                "${data.terraform_remote_state.vpc.aws_subnet_public_a_id}",
                "${data.terraform_remote_state.vpc.aws_subnet_public_b_id}"
              ]

    tags {
        Name = "matabit-alb"
    }

    timeouts {
        create = "10m"
        delete = "10m"
        update = "10m"
    }
    
}
```
We set up our ALB as an external ALB that is attached to public subnets A and B. Also attached is a security group which will limit the type of traffic accepted on the ALB.

## Security group
The following security group configuration will allow in traffic on ports 80 and 443 from any IP and allow outbound traffic on any port to any IP:
```
resource "aws_security_group" "security-lb" {
  description = "Allow the world to use HTTP from the load balancer"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
      Name = "matabit-alb-sg"
  }
}
```

## Listeners
Listeners are used to listen for traffic coming in on defined ports and to take some sort of action on it.
```
resource "aws_alb_listener" "frontend_http" {
    load_balancer_arn = "${aws_lb.alb.arn}"
    port = "80"
    protocol = "HTTP"

    default_action {
        type = "redirect"
        target_group_arn = "${aws_alb_target_group.alb_target_group.id}"
        redirect {
            port = "443"
            protocol = "HTTPS"
            status_code = "HTTP_301"
        }
    }
}
```
This listener is setup to listen out for traffic on port 80 and to forward it on to port 443.

```
resource "aws_alb_listener" "frontend_https" {
    load_balancer_arn = "${aws_lb.alb.arn}"
    port = "443"
    protocol = "HTTPS"
    ssl_policy = "ELBSecurityPolicy-2015-05"
    certificate_arn = "${data.aws_acm_certificate.matabit.arn}"


    default_action {
        type = "forward"
        target_group_arn = "${aws_alb_target_group.alb_target_group.id}"
    }
}
```
This listener is setup to listen for traffic on port 443, decrypt it with the SSL certificate, and send it forward to the target group.

## Target groups
Target groups are destinations for traffic being forwarded by an ALB. Traffic on different ports can be forwarded to different target groups. In this case, we send all traffic towards one target group.
```
resource "aws_alb_target_group" "alb_target_group" {  
    name = "target-group-web"  
    port = "80"  
    protocol = "HTTP"  
    vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"   
    tags {    
        name = "target-group-web"    
    }   
    stickiness {    
        type = "lb_cookie"    
        cookie_duration = 1800    
        enabled = true
    }   
    
    health_check {    
        healthy_threshold = 3    
        unhealthy_threshold = 10    
        timeout = 5    
        interval = 10
        path = "/"    
        port = "80"  
    }
}
```
Health checks are used to ensure the status of registered targets.

## Target group attachments
The following lines are added to attach endpoints for our target group. Two EC2 instances running on our private subnets are attached to our target group so that traffic from the ALB can be sent there.
```
resource "aws_lb_target_group_attachment" "matabit_alb_tg" {
  target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
  target_id        = "${aws_instance.web.id}"
  port             = 80
}
resource "aws_lb_target_group_attachment" "matabit_alb_tg2" {
  target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
  target_id        = "${aws_instance.web2.id}"
  port             = 80
}
```

## Project 3 AWS ALB

For project 3, several things needed to be changed with the ALB file. The first thing was the AWS ACM: a new certificate that includes these SANs:

```
matabit.org, *.matabit.org, *.staging.matabit.org
```

The reason for that was because the ALB Listeners could not resolve the certificate correctly for the *.staging.matabit.org with the containers the way the EC2 instances were able to.

The second thing that was added  is that the ALB now has two target groups which are:

```
target-group-ecs-staging 
target-group-ecs-prod
```

These two target groups are pointing to their respective ECS services that have control over the docker containers. So one for production and one for staging.

The third thing was an additional rule was added to the ALB Listener:

```
resource "aws_lb_listener_rule" "matabit-staging" {
  listener_arn = "${aws_alb_listener.frontend_https.arn}"
  priority = 10

  action = {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.alb_target_group_staging.id}"
  }
  condition = {
    field = "host-header"
    values = ["*staging.matabit.org"]
  }
}
```

The ALB still contains the default rules:

```
#listen on port 80 and redirect to port 443
resource "aws_alb_listener" "frontend_http" {
  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    target_group_arn = "${aws_alb_target_group.alb_target_group_prod.id}"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

#listen on port 443 and forward traffic
resource "aws_alb_listener" "frontend_https" {
  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${data.aws_acm_certificate.matabit.arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.alb_target_group_prod.id}"
  } 
}
```

Whenever the *staging.matabit.org route website is reached it will forward them to the ECS Staging service and all other traffic directed to the ALB will be redirected to the ECS Prod service.


terraform {
    backend "s3" {
        bucket = "matabit-terraform-state-bucket"
        region = "us-west-2"
        dynamodb_table = "matabit-terraform-statelock"
        key = "ALB/terraform.tfstate"
    }
}

#define ALB
resource "aws_lb" "alb" {
    name = "aws-lb-tf"
    internal = false
    load_balancer_type = "application"
    security_groups = ['sg-041946ace3aa221e9','sg-04ea42c6e57a6758a','sg-07ad197331f79dda5','sg-0a97ddd9a5cf26b31']
    subnets = ['subnet-0227801dc0e6c460a','subnet-0227801dc0e6c460a','subnet-0227801dc0e6c460a']
    idle_timeout = "60"
    enable_cross_zone_load_balancing = true
    enable_deletion_protection = true

    access_logs {
        enabled = true
        bucket = "matabit-terraform-state-bucket"
        prefix = "alb_access_logs"
    }

    timeouts {
        create = "10m"
        delete = "10m"
        update = "10m"
    }

}
#listen on port 80 and redirect to port 443
resource "aws_alb_listener" "frontend_http" {
    load_balancer_arn = "${aws_alb.alb.arn}"
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

#listen on port 443 and forward traffic
resource "aws_alb_listener" "frontend_https" {
    load_balancer_arn = "${aws_alb.alb.arn}"
    port = "443"
    protocol = "HTTPS"
    ssl_policy = "ELBSecurityPolicy-2015-05"
    certificate_arn = ""

    default_action {
        type = "forward"
        target_group_arn = "${aws_alb_target_group.alb_target_group.id}"
    }
}

#create target group
resource "aws_alb_target_group" "alb_target_group" {  
    name = "target_group_name"  
    port = "443"  
    protocol = "HTTPS"  
    vpc_id = "matabit-vpc"   
    tags {    
        name = "target_group_name"    
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
        path = ""    
        port = ""  
    }
}


data "aws_acm_certificate" "matabit" {
  domain      = "matabit.org"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

#define ALB
resource "aws_lb" "alb" {
  name                             = "aws-lb"
  internal                         = false
  load_balancer_type               = "application"
  security_groups                  = ["${aws_security_group.security-lb.id}"]
  idle_timeout                     = "60"
  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false

  subnets = [
    "${data.terraform_remote_state.vpc.aws_subnet_public_a_id}",
    "${data.terraform_remote_state.vpc.aws_subnet_public_b_id}",
    "${data.terraform_remote_state.vpc.aws_subnet_public_c_id}"
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

# Security Group: Load Balancer
resource "aws_security_group" "security-lb" {
  description = "Allow the world to use HTTP from the load balancer"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

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

#listen on port 80 and redirect to port 443
resource "aws_alb_listener" "frontend_http" {
  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    target_group_arn = "${aws_alb_target_group.alb_target_group.id}"

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
    target_group_arn = "${aws_alb_target_group.alb_target_group.id}"
  }
}

#create target group
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

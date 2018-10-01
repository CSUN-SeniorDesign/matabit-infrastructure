terraform {
    backend "s3" {
        bucket = "matabit-terraform-state-bucket"
        region = "us-west-2"
        dynamodb_table = "matabit-terraform-statelock"
        key = "ASG/terraform.tfstate"
    }
}

resource "aws_launch_configuration" "asg_conf" {
  name_prefix = "terraform-"
  image_id      = "ami-024186669f68d1d1b"
  instance_type = "t2.micro"
  security_groups = "${aws_security_group.web_sg.id}"

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_placement_group" "aws_placement" {
  name     = "aws_placement"
  strategy = "cluster"
}

resource "aws_autoscaling_group" "asg" {
  name                      = "asg-terraform"
  max_size                  = 2
  min_size                  = 0
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 2
  force_delete              = true
  placement_group           = "${aws_placement_group.aws_placement.id}"
  launch_configuration      = "${aws_launch_configuration.asg_conf.name}"
  vpc_zone_identifier       = ["${aws_subnet.private-subnet-a.id}", "${aws_subnet.private-subnet-b.id}"]
  target_group_arns         = "${aws_alb_target_group.alb_target_group.arn}"

  initial_lifecycle_hook {
    name                 = "ilh"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 2000
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"   
  }
}
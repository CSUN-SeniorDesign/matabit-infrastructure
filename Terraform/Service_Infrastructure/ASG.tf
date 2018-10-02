

resource "aws_launch_configuration" "asg_conf" {
  name_prefix = "terraform-"
  image_id      = "ami-024186669f68d1d1b"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.web_sg.id}"]
  user_data = "${file("../cloud-init.conf")}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                      = "asg-terraform"
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.asg_conf.name}"
  vpc_zone_identifier       = ["${data.terraform_remote_state.vpc.aws_subnet_private_a_id}", "${data.terraform_remote_state.vpc.aws_subnet_private_b_id}"]
  target_group_arns         = ["${aws_alb_target_group.alb_target_group.arn}"]
  wait_for_capacity_timeout = "15m"

  initial_lifecycle_hook {
    name                 = "ilh"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 2000
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"   
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = "${aws_autoscaling_group.asg.id}"
  alb_target_group_arn   = "${aws_alb_target_group.alb_target_group.arn}"
}

resource "aws_autoscaling_schedule" "asg_schedule_on" {
  scheduled_action_name  = "asg_on"
  min_size               = 2
  max_size               = 4
  desired_capacity       = 2
  recurrence             = "0 7 * * *"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}

resource "aws_autoscaling_schedule" "asg_schedule_off" {
  scheduled_action_name  = "asg_off"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = "0 1 * * *"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}


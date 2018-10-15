resource "aws_ecs_cluster" "matabit-cluster" {
  name = "matabit-cluster"
}


data "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"
}


resource "aws_ecs_task_definition" "matabit-prod" {
  family                = "matabit-prod"
  container_definitions = "${file("task-definitions/matabit-prod.json")}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn = "${data.aws_iam_role.ecsTaskExecutionRole.arn}"
  execution_role_arn = "${data.aws_iam_role.ecsTaskExecutionRole.arn}"
  cpu = 256
  memory = 512
}

resource "aws_ecs_task_definition" "matabit-staging" {
  family                = "matabit-staging"
  container_definitions = "${file("task-definitions/matabit-staging.json")}"
  network_mode = "awsvpc"
  task_role_arn = "${data.aws_iam_role.ecsTaskExecutionRole.arn}"
  execution_role_arn = "${data.aws_iam_role.ecsTaskExecutionRole.arn}"
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512
}


resource "aws_ecs_service" "matabit-prod-service" {
  name            = "matabit-prod-service"
  cluster         = "${aws_ecs_cluster.matabit-cluster.id}"
  task_definition = "${aws_ecs_task_definition.matabit-prod.arn}"
  desired_count   = 2
  launch_type = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.security-lb.id}"]

    subnets = [
      "${data.terraform_remote_state.vpc.aws_subnet_public_a_id}",
      "${data.terraform_remote_state.vpc.aws_subnet_public_b_id}",
      "${data.terraform_remote_state.vpc.aws_subnet_public_c_id}",
    ]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
    container_name   = "matabit-prod-container"
    container_port   = 80
  }
}
resource "aws_ecs_service" "matabit-staging-service" {
  name            = "matabit-staging-service"
  cluster         = "${aws_ecs_cluster.matabit-cluster.id}"
  task_definition = "${aws_ecs_task_definition.matabit-staging.arn}"
  desired_count   = 2
  launch_type = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.security-lb.id}"]

    subnets = [
      "${data.terraform_remote_state.vpc.aws_subnet_public_a_id}",
      "${data.terraform_remote_state.vpc.aws_subnet_public_b_id}",
      "${data.terraform_remote_state.vpc.aws_subnet_public_c_id}",
    ]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
    container_name   = "matabit-staging-container"
    container_port   = 80
  }
}


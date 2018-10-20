# AWS Elastic Container Services

AWS Elastic Container Services allow us to create containers out of Docker Images and skip the overhead of having to run entire VM's for our applications.

A container service consists of three parts:

1. Task Definition
2. Task
3. Service
4. Cluster

The *Task definition* defines what type of container we are trying to create and which image we are trying to use.

The *Task* represents the container and tasks belong to *services*.

The *Service* runs a number of container instances defined by the *Task Definition* and ensures that the desired count of instances is always achieved.

The *Cluster* groups all of the different services and tasks into logical sections since some projects can have multiple Services.

# Task Definitions

We currently have two Task Definitions representing our two environments:
1. Production (Prod)
2. Staging

Here is an example of our Production environment.

```JSON
[
    {
      "name": "matabit-prod-container",
      "image": "485876055632.dkr.ecr.us-west-2.amazonaws.com/matabit-ecr:prod",
      "cpu": 10,
      "memory": 512,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ]
    }
]
```

Staging and Prod are identical, except for the fact that we are referencing a different Docker Image out of our ECR.

We are matching container and host port, since that is required by the networking mode that we chose in our Service.

## Terraform

Here is how we create the Task Definition with Terraform

```bash
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
```

Note that `requires_compatibility` and `network_mode` as they are crucial to the settings that we chose. With Fargate we are not required to run EC2 Instance to run our containers on. Fargate takes care of that for us.

The `task_role_arn` and the `execution_role_arn` are identical and give the task definition the bare minimum of permissions to function.

# Service

The service defines how many instances we want for a task definition, which task-definition to use and which cluster the service belongs to.

Additionally, the load balancer definition in the service resource says which target_group the containers should belong to so that the ALB can route the traffic accordingly.

When using Fargate, `assign_public_ip` has to be true if they are placed in public subnets. However, we haven't tested yet if we can turn of the public IP's if we put the services into private subnets. This is why we left the value for `assign_public_ip` to `true` for now. 

```bash
resource "aws_ecs_service" "matabit-prod-service" {
  name            = "matabit-prod-service"
  cluster         = "${aws_ecs_cluster.matabit-cluster.id}"
  task_definition = "${aws_ecs_task_definition.matabit-prod.arn}"
  desired_count   = 2
  launch_type = "FARGATE"
  
  network_configuration {
    security_groups = ["${aws_security_group.security-lb.id}"]
    assign_public_ip = true
    subnets = [
      "${data.terraform_remote_state.vpc.aws_subnet_private_a_id}",
      "${data.terraform_remote_state.vpc.aws_subnet_private_b_id}",
      "${data.terraform_remote_state.vpc.aws_subnet_private_c_id}",
    ]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.alb_target_group_prod.id}"
    container_name   = "matabit-prod-container"
    container_port   = 80
  }
}
```

# Cluster
```bash
resource "aws_ecs_cluster" "matabit-cluster" {
  name = "matabit-cluster"
}
```

That's it. Really.. There's not much to it.
We can safely reference this cluster by ID in other resources.


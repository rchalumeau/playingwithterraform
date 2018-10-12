### ECS

resource "aws_iam_role" "ecs" {
  name               		= "${var.name}-role"
  assume_role_policy 		= "${file("${path.module}/role.json")}"
}

resource "aws_iam_role_policy" "ecs" {

  role   			= "${aws_iam_role.ecs.name}"
  policy 			= "${file("${path.module}/policy.json")}"
}

resource "aws_ecs_cluster" "main" {
  name 				= "${var.name}"
}

resource "aws_ecs_task_definition" "app" {

  family                   	= "${var.app_family}"
  network_mode             	= "awsvpc"

  requires_compatibilities 	= ["FARGATE"]
  cpu                      	= "${var.fargate_cpu}"
  memory                   	= "${var.fargate_memory}"

  container_definitions 	= "${var.definition}"

  task_role_arn      		= "${aws_iam_role.ecs.arn}"
  execution_role_arn 		= "${aws_iam_role.ecs.arn}"
}

resource "aws_ecs_service" "main" {

  name            		= "${var.name}-service"
  cluster         		= "${aws_ecs_cluster.main.id}"

  task_definition 		= "${aws_ecs_task_definition.app.arn}"
  desired_count   		= "${var.app_count}"
  launch_type     		= "FARGATE"

  network_configuration {
    security_groups 		= [ "${var.sg}" ]
    subnets         		= [ "${var.subnet_ids}" ]
  }

  load_balancer {
    target_group_arn 		= "${var.tg}"
    container_name   		= "${var.app_family}"
    container_port   		= "${var.app_port}"
  }
}

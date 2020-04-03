resource "aws_ecs_cluster" "squad_chaws_cluster" {
  name = "squadchawscluster"
}

data "template_file" "squad_chaws_container" {
  template = "${file("templates/squad_container.json")}"

  vars = {
    container_image      = "${var.container_image}"
    container_port       = "${var.container_port}"
    fargate_cpu    = "${var.fargate_cpu}"
    fargate_memory = "${var.fargate_memory}"
    aws_region     = "${var.aws_region}"
  }
}

resource "aws_ecs_task_definition" "squad_chaws_task" {
  family                   = "squadchawstaskfamily"
  execution_role_arn       = "${aws_iam_role.squad_chaws_ecs_task_execution_role.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  container_definitions    = "${data.template_file.squad_chaws_container.rendered}"
}

resource "aws_ecs_service" "squad_chaws_service" {
  name            = "squadservice"
  cluster         = "${aws_ecs_cluster.squad_chaws_cluster.id}"
  task_definition = "${aws_ecs_task_definition.squad_chaws_task.arn}"
  desired_count   = "${var.container_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = ["${aws_security_group.squad_chaws_ecs_tasks_sg.id}"]
    subnets          = ["${aws_subnet.private.*.id}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.squad_chaws_ecs_tg.id}"
    container_name   = "squad-chaws-container"
    container_port   = "${var.container_port}"
  }

  depends_on = ["aws_alb_listener.squad_chaws_alb_listener", "aws_iam_role_policy_attachment.squad_chaws_ecs_task_execution_role_policy_attachment"]
}

resource "aws_alb" "squad_chaws_alb" {
  name            = "squad-chaws-alb"
  subnets         = ["${aws_subnet.public.*.id}"]
  security_groups = ["${aws_security_group.squad_chaws_alb_sg.id}"]
}

resource "aws_alb_target_group" "squad_chaws_ecs_tg" {
  name        = "squad-chaws-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.squad_chaws_vpc.id}"
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "${var.health_check_path}"
    unhealthy_threshold = "2"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "squad_chaws_alb_listener" {
  load_balancer_arn = "${aws_alb.squad_chaws_alb.id}"
  port              = "${var.container_port}"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.squad_chaws_ecs_tg.id}"
    type             = "forward"
  }
}

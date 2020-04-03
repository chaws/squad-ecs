# ALB Security Group: Edit to restrict access to the application
resource "aws_security_group" "squad_chaws_alb_sg" {
  name        = "squad_chaws_alb_sg"
  description = "controls access to the ALB"
  vpc_id      = "${aws_vpc.squad_chaws_vpc.id}"

  ingress {
    protocol    = "tcp"
    from_port   = "${var.container_port}"
    to_port     = "${var.container_port}"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = "80"
    to_port     = "80"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Traffic to the ECS cluster should only come from the ALB
resource "aws_security_group" "squad_chaws_ecs_tasks_sg" {
  name        = "squad_chaws_ecs_tasks_sg"
  description = "allow inbound access from the ALB only"
  vpc_id      = "${aws_vpc.squad_chaws_vpc.id}"

  ingress {
    protocol        = "tcp"
    from_port       = "${var.container_port}"
    to_port         = "${var.container_port}"
    security_groups = ["${aws_security_group.squad_chaws_alb_sg.id}"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = "80"
    to_port     = "80"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

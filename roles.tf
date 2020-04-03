# ECS task execution role data
data "aws_iam_policy_document" "squad_chaws_ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid = ""
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS task execution role
resource "aws_iam_role" "squad_chaws_ecs_task_execution_role" {
  name               = "${var.ecs_task_execution_role_name}"
  assume_role_policy = "${data.aws_iam_policy_document.squad_chaws_ecs_task_execution_role.json}"
}

# ECS task execution role policy attachment
resource "aws_iam_role_policy_attachment" "squad_chaws_ecs_task_execution_role_policy_attachment" {
  role       = "${aws_iam_role.squad_chaws_ecs_task_execution_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
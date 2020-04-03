# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "squad_chaws_log_group" {
  name              = "/ecs/squad-chaws-container"
  retention_in_days = 30

  tags = {
    Name = "squad-chaws-log"
  }
}

resource "aws_cloudwatch_log_stream" "squad_chaws_log_stream" {
  name           = "squad-chaws-log-stream"
  log_group_name = "${aws_cloudwatch_log_group.squad_chaws_log_group.name}"
}

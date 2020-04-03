resource "aws_appautoscaling_target" "squad_chaws_autoscale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.squad_chaws_cluster.name}/${aws_ecs_service.squad_chaws_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 3
  max_capacity       = 6
}

# Automatically scale capacity up by one
resource "aws_appautoscaling_policy" "squad_chaws_scale_up_policy" {
  name               = "squad_chaws_scale_up_policy"
  resource_id        = "${aws_appautoscaling_target.squad_chaws_autoscale_target.resource_id}"
  service_namespace  = "${aws_appautoscaling_target.squad_chaws_autoscale_target.service_namespace}"
  scalable_dimension = "${aws_appautoscaling_target.squad_chaws_autoscale_target.scalable_dimension}"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

# Automatically scale capacity down by one
resource "aws_appautoscaling_policy" "squad_chaws_scale_down_policy" {
  name               = "squad_chaws_scale_down_policy"
  resource_id        = "${aws_appautoscaling_target.squad_chaws_autoscale_target.resource_id}"
  service_namespace  = "${aws_appautoscaling_target.squad_chaws_autoscale_target.service_namespace}"
  scalable_dimension = "${aws_appautoscaling_target.squad_chaws_autoscale_target.scalable_dimension}"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }
}

# CloudWatch alarm that triggers the autoscaling up policy
resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  alarm_name          = "cb_cpu_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "85"

  dimensions = {
    ClusterName = "${aws_ecs_cluster.squad_chaws_cluster.name}"
    ServiceName = "${aws_ecs_service.squad_chaws_service.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.squad_chaws_scale_up_policy.arn}"]
}

# CloudWatch alarm that triggers the autoscaling down policy
resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
  alarm_name          = "cb_cpu_utilization_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    ClusterName = "${aws_ecs_cluster.squad_chaws_cluster.name}"
    ServiceName = "${aws_ecs_service.squad_chaws_service.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.squad_chaws_scale_down_policy.arn}"]
}

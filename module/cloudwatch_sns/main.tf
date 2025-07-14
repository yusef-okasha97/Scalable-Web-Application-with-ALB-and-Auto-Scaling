resource "aws_sns_topic" "alerts" {
  name = "asg-cpu-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "asg-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/AutoScaling"
  period              = 60
  statistic           = "Average"
  threshold           = 50
  alarm_description   = "This metric monitors ASG average CPU utilization."
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
} 
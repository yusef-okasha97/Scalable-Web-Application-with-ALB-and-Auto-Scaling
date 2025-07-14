resource "aws_autoscaling_group" "this" {
  name                      = "web-asg"
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.subnet_ids
  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }
  target_group_arns         = [var.target_group_arn]
  tag {
    key                 = "Name"
    value               = "web-asg-instance"
    propagate_at_launch = true
  }
  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true
}

resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.this.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50
  }
}

output "asg_name" {
  value = aws_autoscaling_group.this.name
} 
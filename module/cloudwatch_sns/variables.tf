variable "asg_name" {
  description = "Name of the Auto Scaling Group to monitor."
  type        = string
}

variable "alert_email" {
  description = "Email address to receive CloudWatch alerts."
  type        = string
}

variable "cpu_threshold" {
  description = "CPU utilization threshold for alarm."
  type        = number
  default     = 80
} 
variable "launch_template_id" {
  description = "ID of the launch template to use for the ASG."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ASG."
  type        = list(string)
}

variable "desired_capacity" {
  description = "Desired number of instances in the ASG."
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances in the ASG."
  type        = number
  default     = 4
}

variable "min_size" {
  description = "Minimum number of instances in the ASG."
  type        = number
  default     = 1
}

variable "target_group_arn" {
  description = "ARN of the ALB target group."
  type        = string
} 
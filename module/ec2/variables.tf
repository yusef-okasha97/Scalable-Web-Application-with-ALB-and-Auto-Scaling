variable "security_group_ids" {
  description = "List of security group IDs for the EC2 instances."
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t2.micro"
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile for EC2 instances."
  type        = string
  default     = ""
} 
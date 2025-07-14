variable "vpc_id" {
  description = "VPC ID for the ALB."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ALB."
  type        = list(string)
}

variable "health_check_path" {
  description = "Path for the ALB health check."
  type        = string
  default     = "/"
} 
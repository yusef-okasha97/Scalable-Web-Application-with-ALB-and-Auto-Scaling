provider "aws" {
  region = "us-east-1"
}

# Create IAM role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Create IAM instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# Attach policies to the role (basic EC2 permissions)
resource "aws_iam_role_policy_attachment" "ec2_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

module "vpc" {
  source = "./module/vpc"
}

module "ec2" {
  source                    = "./module/ec2"
  security_group_ids        = [module.vpc.public_sg_id]
  iam_instance_profile_name = aws_iam_instance_profile.ec2_profile.name
}

module "alb" {
  source     = "./module/alb"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids
}

module "asg" {
  source             = "./module/asg"
  launch_template_id = module.ec2.launch_template_id
  subnet_ids         = module.vpc.public_subnet_ids
  target_group_arn   = module.alb.target_group_arn
  # desired_capacity, min_size, max_size use defaults
}

module "cloudwatch_sns" {
  source     = "./module/cloudwatch_sns"
  asg_name   = module.asg.asg_name
  alert_email = "yusef.okasha97@gmail.com"
  # cpu_threshold uses default (70)
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "sns_topic_arn" {
  value = module.cloudwatch_sns.sns_topic_arn
}
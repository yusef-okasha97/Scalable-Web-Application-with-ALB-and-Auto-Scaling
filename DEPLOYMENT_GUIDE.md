# Quran App Deployment Guide

## Overview
This Terraform configuration deploys a scalable Quran application using:
- EC2 instances with Docker and Docker Compose
- Application Load Balancer (ALB)
- Auto Scaling Group (ASG)
- VPC with security groups
- CloudWatch monitoring with SNS notifications

## Changes Made

### 1. EC2 Module Updates
- **Repository**: Clones your public GitHub repository: `https://github.com/yusef-okasha97/CI-CD-Quran-app-using-Github-action.git`
- **Docker Installation**: Installs Docker and Docker Compose
- **Application Deployment**: Runs your app as a container using `docker-compose up -d`
- **Auto Updates**: Cron job checks for repository updates every 1 minute and rebuilds the container with the latest code

### 2. Security Group Updates
- **HTTP (80)**: ✅ Already configured
- **HTTPS (443)**: ✅ Added
- **Application Port (5050)**: ✅ Added
- **SSH (22)**: ✅ Already configured

### 3. IAM and Key Pair
- **IAM Role**: Created for EC2 instances with basic permissions
- **Instance Profile**: Attached to EC2 instances

## Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **GitHub Repository** must be public or accessible via HTTPS

## Deployment Steps

### 1. Deploy Infrastructure
```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### 2. Access the Application
After deployment, you can access the application via:
- **ALB DNS Name**: Use the output `alb_dns_name`

## Architecture Flow

```
Internet → ALB (Port 80) → EC2 Instances (Port 5050, Docker Container)
```

## Security Features

- **Security Groups**: Restrict access to necessary ports only
- **IAM Roles**: Least privilege access for EC2 instances
- **HTTPS Ready**: Security group allows HTTPS traffic
- **Auto Scaling**: Handles traffic spikes automatically

## Monitoring

- **CloudWatch**: CPU monitoring with SNS notifications
- **Health Checks**: ALB health checks on port 80
- **Auto Recovery**: Failed instances are automatically replaced

## Troubleshooting

### Common Issues

1. **Docker not starting**: Check EC2 instance logs
2. **Application not accessible**: Verify security groups and ALB configuration
3. **Git clone fails**: Ensure repository is public or accessible

### Useful Commands

```bash
# SSH to EC2 instance (if you add a key pair)
ssh -i <your-key.pem> ubuntu@<EC2-IP>

# Check Docker containers
docker ps

# View application logs
docker-compose logs

# Check cron jobs
crontab -l
```

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```

## Notes

- The application automatically updates every 1 minute by pulling from the main branch
- Docker containers are rebuilt on each update
- The ALB distributes traffic across multiple EC2 instances for high availability
- This setup is suitable for any containerized app, such as your sound app, and is production-ready for high availability and scalability. 
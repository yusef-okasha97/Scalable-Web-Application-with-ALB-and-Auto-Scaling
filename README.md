# Scalable Quran App Deployment with Terraform

## Overview
This project provides Terraform code to deploy a scalable Quran application (or any containerized app, such as a sound app) on AWS. The app runs in Docker containers on EC2 instances, is automatically updated from your public GitHub repository every minute, and is accessible publicly via an Application Load Balancer (ALB).

## 📚 Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Key Features](#key-features)
- [Table of Contents](#table-of-contents)
- [Terraform Modules](#terraform-modules)
- [Monitoring & Alerts](#monitoring--alerts)
- [Quick Start](#quick-start)
- [How Auto-Update Works](#how-auto-update-works)
- [More Information](#more-information)

## 🖼 Architecture
```
Internet → ALB (Port 80/443) → EC2 Auto Scaling Group (Docker Compose, App on Port 5050)
```
- **ALB**: Handles incoming HTTP/HTTPS traffic and forwards it to EC2 instances
- **EC2 Instances**: Run Docker Compose, which launches your app container (listening on port 5050)
- **Auto Scaling Group**: Ensures high availability and scales based on load
- **CloudWatch & SNS**: Monitoring and alerting for CPU and health

## Key Features
- **Automatic Deployment**: Clones your public GitHub repository and runs the app as a Docker container
- **Auto-Update**: Every 1 minute, the app pulls the latest code and rebuilds the container (using `docker-compose build --no-cache`)
- **Public Access**: ALB forwards traffic to your app (default port 5050 on EC2)
- **Production-Ready**: High availability, scalability, and monitoring
- **No Nginx or static HTML**: The app is served directly from the Docker container

## 🧱 Terraform Modules
| Module             | Purpose                                                      |
|--------------------|--------------------------------------------------------------|
| `vpc`              | Defines VPC, public subnets, route tables, and security groups|
| `ec2`              | Creates Launch Template and UserData for Dockerized app      |
| `alb`              | Provisions Application Load Balancer, target group, listener |
| `asg`              | Auto Scaling Group with scaling policies                     |
| `cloudwatch_sns`   | CloudWatch alarms and SNS notifications for monitoring       |

## 📊 Monitoring & Alerts
- **CloudWatch Alarms**: Monitor EC2 CPU utilization and Auto Scaling Group health.
- **SNS Notifications**: Receive email alerts when thresholds (like high CPU) are breached.
- **Automatic Recovery**: Failed or unhealthy instances are replaced automatically.
- **Visibility**: Monitor metrics and alarms in the AWS Console.

See [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) for more details on monitoring and alerting setup.

## Quick Start
### Prerequisites
- AWS Account with appropriate permissions
- AWS CLI configured with credentials
- Terraform installed (version >= 1.0)
- Public GitHub repository with a valid `docker-compose.yml` and your app code

### Deployment Steps
1. **Clone this repository**
   ```bash
   git clone <your-repository-url>
   cd Manara-project
   ```
2. **Initialize Terraform**
   ```bash
   terraform init
   ```
3. **Plan the deployment**
   ```bash
   terraform plan
   ```
4. **Apply the configuration**
   ```bash
   terraform apply
   ```
5. **Access your app**
   - After deployment, get the ALB DNS name:
     ```bash
     terraform output alb_dns_name
     ```
   - Open the DNS name in your browser. The ALB forwards to your app running on port 5050 inside the EC2 instances.

## How Auto-Update Works
- A cron job runs every 1 minute on each EC2 instance:
  - Pulls the latest code from your GitHub repo (`git pull origin main`)
  - Rebuilds the Docker image with `docker-compose build --no-cache`
  - Restarts the container with the new code
- Any change you push to your repo will be live within 1 minute!

3. **Test auto-scaling**:
   - SSH into an instance and run stress test
   - Monitor scaling in AWS Console

4. **Check alerts**:
   - Confirm SNS email subscription
   - Monitor CloudWatch alarms

Your scalable web application is now ready with automatic scaling, load balancing, and monitoring! 
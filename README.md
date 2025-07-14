## 🧩 Solution Overview

Deploy a scalable web application on AWS using EC2 instances with Application Load Balancer (ALB) and Auto Scaling Groups (ASG). The project demonstrates best practices for compute scalability, security, monitoring, and cost optimization with a focus on Free Tier eligibility.

This solution automatically provisions networking, compute, load balancing, monitoring, and alerting resources in a modular fashion. The infrastructure follows AWS best practices and supports the following capabilities:

- **Web Tier**: EC2 instances in Auto Scaling Groups (ASGs) across multiple Availability Zones
- **Load Balancing**: Application Load Balancer (ALB) for traffic distribution and health checks
- **Auto Scaling**: Dynamic scaling based on CPU utilization (target: 50%)
- **Monitoring**: CloudWatch alarms and SNS notifications for performance monitoring
- **Security**: Security Groups with least-privilege access control
- **Free Tier Optimized**: Uses t2.micro instances and Ubuntu 20.04 LTS

The infrastructure automatically fetches and serves an `index.html` file from your GitHub repository every minute, ensuring content is always up-to-date. This solution can serve as a production-ready base infrastructure for hosting modern web applications with high availability and scalability.

---

## 📚 Table of Content

- [Solution Overview](#solution-overview)  
- [Architecture Diagram](#architecture-diagram)  
- [Terraform Modules](#terraform-modules)  
- [Component Breakdown](#component-breakdown)  
- [Customizing the Solution](#customizing-the-solution)  
- [Prerequisites for Deployment](#prerequisites-for-deployment)  
  1. [Clone the Repository](#1-clone-the-repository)  
  2. [Initialize and Validate](#2-initialize-and-validate)  
  3. [Build & Deploy](#3-build--deploy)  
- [Testing Auto Scaling](#testing-auto-scaling)
- [Monitoring & Alerts](#monitoring--alerts)
- [Operational Metrics](#operational-metrics)  
- [Troubleshooting](#troubleshooting)
- [External Contributors](#external-contributors)  
---

## 🖼 Architecture Diagram

The scalable web application architecture consists of the following components:

1. **Web Tier**
   - EC2 instances deployed in public subnets across 2 Availability Zones
   - Auto Scaling Group (ASG) with target tracking scaling policy (CPU > 50%)
   - Launch Template with UserData that installs Nginx and fetches content from GitHub
   - Instances automatically update `index.html` every minute from your repository

2. **Load Balancing Tier**
   - Application Load Balancer (ALB) in public subnets
   - Target Group with health checks on port 80
   - HTTP listener on port 80
   - Distributes traffic across healthy EC2 instances

3. **Networking**
   - VPC with public subnets across 2 Availability Zones
   - Internet Gateway for internet access
   - Route tables configured for public internet access
   - Security Groups for ALB and EC2 instances

4. **Monitoring & Alerting**
   - CloudWatch alarms for CPU utilization monitoring
   - SNS topic for email notifications
   - Immediate alerts when CPU exceeds 50% for 1 minute

5. **Security**
   - Security Groups with HTTP (80) and SSH (22) access
   - ALB Security Group allows inbound HTTP traffic
   - EC2 Security Group allows HTTP and SSH from anywhere

The overall infrastructure is highly modular, making it easy to extend with services like HTTPS, WAF, or additional monitoring.

---

## 🧱 Terraform Modules

The project is structured using isolated modules to separate concerns and ease maintenance.

| Module           | Purpose                                      |
|------------------|----------------------------------------------|
| `vpc`            | Defines VPC, public subnets, route tables, and security groups |
| `ec2`            | Creates Launch Template with UserData for Nginx installation |
| `alb`            | Provisions Application Load Balancer, target group, and listener |
| `asg`            | Auto Scaling Group with CPU-based scaling policies |
| `cloudwatch_sns` | CloudWatch alarms and SNS notifications for monitoring |

---

## 🧩 Component Breakdown

### VPC & Networking
- Custom VPC with public subnets across 2 AZs (us-east-1a, us-east-1b)
- Internet Gateway for internet access
- Route tables configured for public subnets
- Security Groups for ALB and EC2 instances

### Application Load Balancer
- Internet-facing ALB in public subnets
- Target Group with health checks on port 80
- HTTP listener on port 80
- Security Group allowing inbound HTTP traffic

### Auto Scaling Groups
- ASG spanning both public subnets
- Target tracking scaling policy (CPU > 50%)
- Launch Template with Ubuntu 20.04 LTS and t2.micro instances
- Health checks and grace period configured

### EC2 & User Data
- Launch Template with UserData script that:
  - Installs Nginx, Git, and Curl
  - Creates a script to fetch `index.html` from GitHub
  - Sets up cron job to update content every minute
  - Starts and enables Nginx service

### CloudWatch & Monitoring
- CloudWatch alarm for ASG average CPU utilization
- SNS topic for email notifications
- Immediate alerts when CPU exceeds 50% for 1 minute

---

## ⚙️ Customizing the Solution

You can easily tailor this infrastructure by:
- Updating the GitHub repository URL in the EC2 UserData script
- Modifying the CPU threshold for auto-scaling (currently 50%)
- Changing the instance type (currently t2.micro for Free Tier)
- Adding HTTPS support with SSL certificates
- Extending with additional monitoring metrics

---

## 🛠 Prerequisites for Deployment

### Required
- AWS Account with appropriate permissions
- Terraform installed (version >= 1.0)
- AWS CLI configured with credentials
- GitHub repository with an `index.html` file

### Recommended
- SSH key pair for EC2 access (optional)
- Email address for CloudWatch alerts

---

### 1. Clone the Repository

```bash
git clone <your-repository-url>
cd Manara-project
```

### 2. Initialize and Validate

```bash
terraform init
terraform validate
```

### 3. Build & Deploy

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

After deployment, you'll receive:
- ALB DNS name for accessing your web application
- SNS topic ARN for monitoring
- Email confirmation for CloudWatch alerts

---

## 🧪 Testing Auto Scaling

To test the auto-scaling functionality:

1. **SSH into an EC2 instance** (get public IP from AWS Console)
2. **Install and run stress tool**:
   ```bash
   sudo apt-get update
   sudo apt-get install -y stress
   stress --cpu 2 --timeout 300
   ```
3. **Monitor scaling activity** in AWS Console:
   - Go to EC2 → Auto Scaling Groups → web-asg
   - Check the "Activity" tab for scaling events
4. **Check CloudWatch alarms** for alert status

---

## 📊 Monitoring & Alerts

### CloudWatch Alarms
- **CPU Utilization**: Triggers when ASG average CPU > 50% for 1 minute
- **Email Notifications**: Sent to configured email address via SNS

### SNS Notifications
- Email alerts for high CPU utilization
- Confirmation email required after first deployment
- Check spam/junk folder for confirmation emails

### Monitoring Dashboard
- ASG metrics in CloudWatch console
- ALB metrics and target group health
- EC2 instance metrics and status

---

## 📈 Operational Metrics

Monitored through AWS CloudWatch:
- **EC2 Instance**: CPU utilization, status checks
- **Auto Scaling**: Group size, scaling activities, health status
- **Application Load Balancer**: Request count, target response time, healthy/unhealthy targets
- **Custom Metrics**: GitHub content update frequency (via cron logs)

---

## 🔧 Troubleshooting

### Common Issues

1. **No email alerts received**
   - Check for SNS subscription confirmation email
   - Verify email address in Terraform configuration
   - Check spam/junk folder

2. **ASG not scaling**
   - Verify scaling policy is attached to ASG
   - Check ASG max_size is greater than current instances
   - Ensure CPU load is generated on all instances

3. **ALB not accessible**
   - Verify security groups allow HTTP traffic
   - Check target group health status
   - Confirm instances are in running state

4. **Content not updating**
   - Check GitHub repository accessibility
   - Verify cron job is running on instances
   - Review UserData script execution

### Useful Commands

```bash
# Check Terraform state
terraform show

# View outputs
terraform output

# Destroy infrastructure
terraform destroy
```

---

## 🤝 External Contributors

Contributions are welcome! If you want to enhance or fix something:
- Fork the repository
- Commit your changes
- Open a Pull Request with a description

Make sure to run:
```bash
terraform fmt
terraform validate
terraform plan
```

## 🚀 Quick Start

1. **Deploy the infrastructure**:
   ```bash
   terraform init && terraform apply
   ```

2. **Access your web application**:
   ```bash
   terraform output alb_dns_name
   ```

3. **Test auto-scaling**:
   - SSH into an instance and run stress test
   - Monitor scaling in AWS Console

4. **Check alerts**:
   - Confirm SNS email subscription
   - Monitor CloudWatch alarms

Your scalable web application is now ready with automatic scaling, load balancing, and monitoring!

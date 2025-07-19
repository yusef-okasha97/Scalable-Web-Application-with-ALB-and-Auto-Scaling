locals {
  user_data = <<-EOF
    #!/bin/bash
    set -e  # Exit on any error
    
    # Update system packages
    apt-get update -y
    apt-get install -y git curl software-properties-common apt-transport-https ca-certificates gnupg lsb-release
    
    # Install Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io
    
    # Install Docker Compose
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    # Start and enable Docker service
    systemctl start docker
    systemctl enable docker
    
    # Clone the repository using HTTPS
    cd /opt
    git clone https://github.com/yusef-okasha97/CI-CD-Quran-app-using-Github-action.git quran-app
    cd quran-app
    
    # Run the application with docker-compose
    docker-compose up -d
    
    # Create a script to update the application
    cat > /usr/local/bin/update_app.sh << 'UPDATE_SCRIPT'
    #!/bin/bash
    set -e  # Exit on any error
    
    cd /opt/quran-app
    
    # Pull latest changes
    git pull origin main || exit 1
    
    # Stop containers
    docker-compose down || true
    
    # Remove old images to force rebuild
    docker-compose build --no-cache || exit 1
    
    # Start containers with new images
    docker-compose up -d || exit 1
    
    # Log the update
    echo "$(date): Application updated successfully" >> /var/log/app-updates.log
    UPDATE_SCRIPT
    chmod +x /usr/local/bin/update_app.sh
    
    # Copy script to ubuntu's home and set permissions
    cp /usr/local/bin/update_app.sh /home/ubuntu/update_app.sh
    chown ubuntu:ubuntu /home/ubuntu/update_app.sh
    chmod +x /home/ubuntu/update_app.sh

    # Add cron job for ubuntu user (idempotent)
    crontab -u ubuntu -l 2>/dev/null | grep -v 'update_app.sh' > /tmp/ubuntu_cron
    echo "* * * * * /home/ubuntu/update_app.sh # Auto-update app" >> /tmp/ubuntu_cron
    crontab -u ubuntu /tmp/ubuntu_cron
    rm /tmp/ubuntu_cron
  EOF
}

resource "aws_launch_template" "this" {
  name_prefix   = "asg-lt-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  user_data     = base64encode(local.user_data)
  vpc_security_group_ids = var.security_group_ids
  
  # Add IAM instance profile for better security
  iam_instance_profile {
    name = var.iam_instance_profile_name
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
} 

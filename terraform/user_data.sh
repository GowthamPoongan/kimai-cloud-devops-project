#!/bin/bash
set -e

# Create 1GB swap to handle memory pressure
fallocate -l 1G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=1024
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

# Update and install dependencies using dnf (Amazon Linux 2023)
dnf update -y
dnf install -y docker git

# Start Docker and enable on boot
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# Install Docker Compose (V2)
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Clone Kimai app as ec2-user
runuser -l ec2-user -c '
cd ~
git clone https://github.com/GowthamPoongan/kimai-app.git
cd kimai-app
sed -i "s/8010:8001/8001:8001/" docker-compose.yml
/usr/local/bin/docker-compose up -d
'

# Wait for Kimai startup
sleep 30

# Run Jenkins container
docker run -d \
  --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v /var/jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts

# Store Jenkins initial admin password
sleep 30
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword > /home/ec2-user/jenkins-password.txt


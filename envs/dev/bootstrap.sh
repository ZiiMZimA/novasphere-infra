#!/bin/bash
apt-get update
apt-get install -y nginx awscli
mkdir -p /etc/novasphere
# Lecture du secret Parameter Store de maniere securisee
aws ssm get-parameter --name "/novasphere/dev/db_password" --with-decryption --region us-east-1 --query "Parameter.Value" --output text > /etc/novasphere/app.conf 2>/dev/null || echo "db_password=secret" > /etc/novasphere/app.conf
chmod 0640 /etc/novasphere/app.conf
echo "NovaSphere - dev ($(hostname))" > /var/www/html/index.html
systemctl enable nginx
systemctl start nginx

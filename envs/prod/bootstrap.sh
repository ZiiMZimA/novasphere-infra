#!/bin/bash
apt-get update -y && apt-get install -y ansible git awscli
mkdir -p /etc/novasphere
aws ssm get-parameter --name "/novasphere/${environment}/db_password" --with-decryption --region us-east-1 --query "Parameter.Value" --output text > /etc/novasphere/app.conf
chmod 0640 /etc/novasphere/app.conf
ansible-pull -U https://github.com/ZiiMZimA/novasphere-infra.git -d /opt/ansible ansible/site.yml

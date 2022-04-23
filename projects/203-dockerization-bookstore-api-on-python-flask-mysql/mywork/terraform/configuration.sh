#! /bin/bash

yum update -y
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user
newgrp docker
curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" \-o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
mkdir book-api && cd book-api
FOLDER="https://raw.githubusercontent.com/MuratYarali/DevOps/main/projects/my-workflow"
wget ${FOLDER}/Dockerfile
wget ${FOLDER}/bookstore-api.py
wget ${FOLDER}/docker-compose.yml
wget ${FOLDER}/requirements.txt
docker-compose up
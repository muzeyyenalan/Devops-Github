#! /bin/bash

yum update -y
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user
newgrp docker
# install docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" \
-o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
mkdir book-api && cd book-api
FOLDER = "https://raw.githubusercontent.com/muzeyyenalan/Devops-Github/main/projects/203-dockerization-bookstore-api-on-python-flask-mysql/mywork"
wget ${FOLDER}/Dockerfile
wget ${FOLDER}/docker-compose.yml
wget ${FOLDER}/requirements.txt
wget ${FOLDER}/
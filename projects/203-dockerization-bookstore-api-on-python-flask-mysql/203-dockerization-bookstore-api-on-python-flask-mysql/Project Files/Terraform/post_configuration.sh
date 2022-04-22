#! /bin/bash
yum update -y
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
systemctl status docker
usermod -a -G docker ec2-user # add user to docker group
newgrp docker
docker version
curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" \
-o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
mkdir book-api && cd book-api
FOLDER="https://raw.githubusercontent.com/engingltekin/devops/main/Docker/203-dockerization-bookstore-api-on-python-flask-mysql"
wget ${FOLDER}/requirements.txt
wget ${FOLDER}/bookstore-api.py
wget ${FOLDER}/Dockerfile
wget ${FOLDER}/docker-compose.yml
docker-compose up

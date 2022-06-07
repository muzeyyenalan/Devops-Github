#! /bin/bash
yum update -y
yum install java-1.8.0-openjdk -y
yum install unzip wget -y
cd /tmp
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.63/bin/apache-tomcat-9.0.63.zip
unzip apache-tomcat-*.zip
mv apache-tomcat-9.0.63 /opt/tomcat
chmod +x /opt/tomcat/bin/*
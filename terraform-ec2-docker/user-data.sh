#!/bin/bash
yum update -y
amazon-linux-extras install docker -y
service docker start
usermod -a -G docker ec2-user

docker pull yogeshdhdocker/github-vm-place-app:latest

docker run -d -p 8080:8080 yogeshdhdocker/github-vm-place-app:latest

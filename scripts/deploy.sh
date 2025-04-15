#!/bin/bash

set -e

ECR_REPO_URL=$1
IMAGE_TAG=$2
CONTAINER_NAME="vmp-java-app"

echo "Logging in to ECR..."
if ! aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "$ECR_REPO_URL"
  echo "ECR login failed!"
  exit 1
fi  

echo "Stopping old container if exists..."
docker stop $CONTAINER_NAME || true
docker rm $CONTAINER_NAME || true

echo "Pulling latest image from ECR..."
docker pull "$ECR_REPO_URL:$IMAGE_TAG"

echo "Running new container..."
docker run -d --name $CONTAINER_NAME -p 8080:9193 \
  --env SPRING_PROFILES_ACTIVE=aws \
  --env-file /home/ec2-user/vmp-env.list \
  "$ECR_REPO_URL:$IMAGE_TAG"

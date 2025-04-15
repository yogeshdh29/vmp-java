#!/bin/bash

set -e

ECR_REPO_URL=$1
IMAGE_TAG=$2
CONTAINER_NAME="vmp-java-app"

echo "Setting AWS credentials..."
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
export AWS_DEFAULT_REGION=us-east-1

echo "Logging in to ECR..."
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "$ECR_REPO_URL"

echo "Stopping old container if exists..."
docker stop $CONTAINER_NAME || true
docker rm $CONTAINER_NAME || true

echo "Pulling latest image from ECR..."
docker pull "$ECR_REPO_URL:$IMAGE_TAG"

echo "Running new container..."
docker run -d --name $CONTAINER_NAME -p 8080:8080 \
  --env SPRING_PROFILES_ACTIVE=aws \
  --env-file /home/ec2-user/vmp-env.list \
  "$ECR_REPO_URL:$IMAGE_TAG"

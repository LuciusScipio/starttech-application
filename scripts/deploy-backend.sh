#!/bin/bash
# 1. Variables
AWS_REGION="us-east-1"
ECR_REPO_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/starttech-backend"

# 2. Login to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO_URL

# 3. Pull the latest image
docker pull $ECR_REPO_URL:latest

# 4. Stop and remove old container if it exists
docker stop backend-api || true
docker rm backend-api || true

# 5. Run the new container
# We pass sensitive data via environment variables loaded from the host
docker run -d \
  --name backend-api \
  -p 8080:8080 \
  -e MONGO_URI="$MONGO_URI" \
  -e REDIS_ADDR="$REDIS_ADDR" \
  -e JWT_SECRET_KEY="$JWT_SECRET_KEY" \
  $ECR_REPO_URL:latest
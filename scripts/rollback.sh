#!/bin/bash
set -e

# Configuration
REGISTRY_URL="611483456718.dkr.ecr.us-east-1.amazonaws.com"
REPOSITORY_NAME="starttech-backend"
CONTAINER_NAME="muchtodo-api"
LOG_GROUP="/aws/starttech/application"

echo "===================================================="
echo "🚨 STARTTECH CRITICAL ROLLBACK PROTOCOL ACTIVATED 🚨"
echo "===================================================="

# 1. Fetch the second most recent image tag from ECR (the previous stable build)
echo "🔍 Fetching previous stable deployment tag from Amazon ECR..."
PREVIOUS_TAG=$(aws ecr describe-images \
    --repository-name "$REPOSITORY_NAME" \
    --query 'sort_by(imageDetails, &imagePushedAt)[-2].imageTags[0]' \
    --output text)

if [ "$PREVIOUS_TAG" == "None" ] || [ -z "$PREVIOUS_TAG" ]; then
    echo "❌ Error: Could not locate a previous image version in ECR to roll back to."
    exit 1
fi

echo "✅ Found previous stable version tag: $PREVIOUS_TAG"

# 2. Authenticate local Docker daemon with ECR
echo "🔐 Re-authenticating local Docker engine with ECR..."
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "$REGISTRY_URL"

# 3. Pull the fallback version image
echo "📥 Pulling rollback target image: $REGISTRY_URL/$REPOSITORY_NAME:$PREVIOUS_TAG..."
docker pull "$REGISTRY_URL/$REPOSITORY_NAME:$PREVIOUS_TAG"

# 4. Gracefully terminate and remove the faulty active container
if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "🛑 Disabling and removing active broken container..."
    docker stop "$CONTAINER_NAME"
    docker rm "$CONTAINER_NAME"
fi

# 5. Bring up the stable rollback container using local instance system configuration
echo "🚀 Spawning previous stable release container..."
docker run -d \
  --name "$CONTAINER_NAME" \
  --restart always \
  -p 8080:8080 \
  -e MONGO_URI="$MONGO_URI" \
  -e REDIS_ADDR="$REDIS_ADDR" \
  -e PORT="8080" \
  -e JWT_SECRET_KEY="$JWT_SECRET_KEY" \
  --log-driver=awslogs \
  --log-opt awslogs-group="$LOG_GROUP" \
  --log-opt awslogs-stream="ec2-rollback-$(curl -s http://169.254.169.254/latest/meta-data/instance-id)" \
  "$REGISTRY_URL/$REPOSITORY_NAME:$PREVIOUS_TAG"

echo "===================================================="
echo "🎉 ROLLBACK COMPLETED SUCCESSFULLY"
echo "Active runtime version: $PREVIOUS_TAG"
echo "===================================================="
#!/bin/bash
set -e

# Configuration Requirements
DIST_DIRECTORY="./frontend/dist"

echo "===================================================="
echo "📦 STARTTECH FRONTEND APPLICATION DEPLOYMENT"
echo "===================================================="

# 1. Input parameters validation
if [ -z "$S3_BUCKET_NAME" ] || [ -z "$CLOUDFRONT_DIST_ID" ]; then
    echo "❌ Error: Missing required system variables: S3_BUCKET_NAME and CLOUDFRONT_DIST_ID must be set."
    exit 1
fi

# 2. Change workspace context to the frontend codebase
if [ -d "./frontend" ]; then
    cd ./frontend
fi

# 3. Clean environment workspace installation and validation
echo "🛠️ Compiling clean production bundles via npm..."
npm ci
npm run build

# 4. Synchronize static bundle with AWS S3 distribution targets
echo "🚀 Syncing distribution objects to AWS S3 (Bucket: $S3_BUCKET_NAME)..."
aws s3 sync ./dist/ "s3://$S3_BUCKET_NAME" --delete

# 5. Invalidate edge distribution records across CloudFront CDN
echo "⚡ Purging edge memory caches across CloudFront Distribution: $CLOUDFRONT_DIST_ID..."
aws cloudfront create-invalidation --distribution-id "$CLOUDFRONT_DIST_ID" --paths "/*"

echo "===================================================="
echo "🎉 FRONTEND DISPATCH COMPLETE: Static sites are live!"
echo "===================================================="
#!/bin/bash

# Target definitions (Fallback to localhost if executed directly on the EC2 node)
TARGET_URL=${1:-"http://localhost:8080"}
MAX_ATTEMPTS=6
WAIT_INTERVAL_SECS=10

echo "🔍 Starting Application Health Verification Pipeline..."
echo "Target Base Endpoint: $TARGET_URL"

for ((attempt=1; attempt<=MAX_ATTEMPTS; attempt++))
do
    echo "📥 Attempt $attempt/$MAX_ATTEMPTS: Pinging /ping endpoint..."
    
    # Execute network lookup capturing HTTP status codes cleanly
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET_URL/ping" --max-time 5)
    
    if [ "$HTTP_STATUS" -eq 200 ]; then
        echo "💚 Health validation check passed! API is returning HTTP 200 OK."
        exit 0
    else
        echo "⚠️ Warning: Endpoint returned unexpected status code ($HTTP_STATUS). Retrying..."
    fi
    
    sleep "$WAIT_INTERVAL_SECS"
done

echo "❌ Error: Application failed health validation probes after $((MAX_ATTEMPTS * WAIT_INTERVAL_SECS)) seconds."
exit 1
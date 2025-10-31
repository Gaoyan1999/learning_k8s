#!/bin/bash
# Script to build and start the Java + MySQL multi-container app

set -e

echo "🔹 Starting Docker Compose environment..."
docker-compose up --build -d

echo "✅ Containers started!"
echo "Use 'docker-compose logs -f backend' to see backend output."

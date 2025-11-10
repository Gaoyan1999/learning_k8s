#!/bin/bash

# Build and push Docker images to ECR for EKS deployment
# This script builds images and pushes them to AWS ECR

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_SOURCE_DIR="${SCRIPT_DIR}/../stage0-docker-basics/003_stardard_backend"
FRONTEND_DIR="${SCRIPT_DIR}/frontend"

# Configuration - Update these values
AWS_REGION="${AWS_REGION:-ap-southeast-2}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo '')}"
ECR_REPOSITORY_PREFIX="${ECR_REPOSITORY_PREFIX:-learning-k8s}"

if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "❌ AWS_ACCOUNT_ID is not set and cannot be retrieved."
    echo "Please set AWS_ACCOUNT_ID or configure AWS CLI:"
    echo "  export AWS_ACCOUNT_ID=your-account-id"
    echo "  aws configure"
    exit 1
fi

ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
BACKEND_IMAGE="${ECR_REGISTRY}/${ECR_REPOSITORY_PREFIX}-backend:latest"
FRONTEND_IMAGE="${ECR_REGISTRY}/${ECR_REPOSITORY_PREFIX}-frontend:latest"

echo "🔨 Building and pushing Docker images to ECR..."
echo "Registry: ${ECR_REGISTRY}"
echo "Region: ${AWS_REGION}"
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

# Login to ECR
echo "🔐 Logging in to ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}

# Create ECR repositories if they don't exist
echo "📦 Creating ECR repositories if needed..."
aws ecr describe-repositories --repository-names ${ECR_REPOSITORY_PREFIX}-backend --region ${AWS_REGION} &>/dev/null || \
    aws ecr create-repository --repository-name ${ECR_REPOSITORY_PREFIX}-backend --region ${AWS_REGION}

aws ecr describe-repositories --repository-names ${ECR_REPOSITORY_PREFIX}-frontend --region ${AWS_REGION} &>/dev/null || \
    aws ecr create-repository --repository-name ${ECR_REPOSITORY_PREFIX}-frontend --region ${AWS_REGION}

# Build and push backend image
echo "🔧 Building backend image..."
if [ -d "$BACKEND_SOURCE_DIR" ]; then
    cd "$BACKEND_SOURCE_DIR"
    docker build -t ${ECR_REPOSITORY_PREFIX}-backend:latest .
    docker tag ${ECR_REPOSITORY_PREFIX}-backend:latest ${BACKEND_IMAGE}
    echo "📤 Pushing backend image to ECR..."
    docker push ${BACKEND_IMAGE}
    echo "✅ Backend image pushed successfully: ${BACKEND_IMAGE}"
else
    echo "❌ Backend source directory not found: $BACKEND_SOURCE_DIR"
    exit 1
fi

# Build and push frontend image
echo "🎨 Building frontend image..."
if [ -d "$FRONTEND_DIR" ]; then
    cd "$FRONTEND_DIR"
    docker build -t ${ECR_REPOSITORY_PREFIX}-frontend:latest .
    docker tag ${ECR_REPOSITORY_PREFIX}-frontend:latest ${FRONTEND_IMAGE}
    echo "📤 Pushing frontend image to ECR..."
    docker push ${FRONTEND_IMAGE}
    echo "✅ Frontend image pushed successfully: ${FRONTEND_IMAGE}"
else
    echo "❌ Frontend directory not found: $FRONTEND_DIR"
    exit 1
fi

echo ""
echo "✅ All images built and pushed successfully!"
echo ""
echo "📦 Image URLs:"
echo "  Backend:  ${BACKEND_IMAGE}"
echo "  Frontend: ${FRONTEND_IMAGE}"
echo ""
echo "💡 Update your deployment YAML files with these image URLs"

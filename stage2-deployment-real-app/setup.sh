#!/bin/bash

# EKS Deployment Setup Script
# This script deploys the full-stack application to EKS

set -e

echo "🚀 Starting Stage 3 deployment to EKS..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if we can connect to cluster
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster."
    echo "Please make sure you have configured kubeconfig:"
    echo "  aws eks update-kubeconfig --name <cluster-name> --region <region>"
    exit 1
fi

echo "✅ Connected to cluster: $(kubectl config current-context)"
echo ""

# Check if images are set in environment, if not, construct them automatically
# Always construct BACKEND_IMAGE and FRONTEND_IMAGE automatically, ignore any environment variable.
echo "⚠️  BACKEND_IMAGE and FRONTEND_IMAGE not set (always using auto-construction)..."

# Get AWS account ID and region
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo '')}"
AWS_REGION="${AWS_REGION:-ap-southeast-2}"

if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "❌ Cannot get AWS_ACCOUNT_ID. Please set it manually:"
    echo "  export AWS_ACCOUNT_ID=<your-account-id>"
    exit 1
fi

ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
export BACKEND_IMAGE="${ECR_REGISTRY}/learning-k8s-backend:latest"
export FRONTEND_IMAGE="${ECR_REGISTRY}/learning-k8s-frontend:latest"

echo "✅ Auto-constructed image URLs:"
echo "  Backend:  ${BACKEND_IMAGE}"
echo "  Frontend: ${FRONTEND_IMAGE}"
echo ""

# Step 1: Create ConfigMap and Secret
echo "🔐 Creating ConfigMap and Secret for MySQL..."
kubectl apply -f mysql-config.yaml

# Step 2: Deploy MySQL
echo "🗄️  Deploying MySQL..."
kubectl apply -f mysql-deployment.yaml

# Wait for MySQL to be ready
echo "⏳ Waiting for MySQL to be ready..."
sleep 30

# Step 3: Create backend ConfigMap
echo "⚙️  Creating backend ConfigMap..."
kubectl apply -f backend-config.yaml

# Step 4: Deploy backend
echo "🔧 Deploying backend..."
# Use envsubst to replace image URL
envsubst < backend-deployment.yaml | kubectl apply -f -

# Step 5: Deploy frontend
echo "🎨 Deploying frontend..."
# Use envsubst to replace image URL
envsubst < frontend-deployment.yaml | kubectl apply -f -

# Step 6: Deploy frontend LoadBalancer service
echo "🌐 Deploying frontend LoadBalancer service..."
kubectl apply -f frontend-service-lb.yaml

# Wait a bit for pods to start
echo "⏳ Waiting for pods to start..."
sleep 20

# Show status
echo ""
echo "📊 Deployment Status:"
echo "===================="
kubectl get pods
echo ""
echo "🌐 Services:"
echo "============"
kubectl get svc
echo ""

# Wait for LoadBalancer to get external IP
echo "⏳ Waiting for LoadBalancer to get external IP..."
echo "This may take 1-2 minutes..."

for i in {1..30}; do
    EXTERNAL_IP=$(kubectl get svc frontend-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
    if [ -n "$EXTERNAL_IP" ]; then
        echo ""
        echo "✅ Deployment complete!"
        echo ""
        echo "📝 Access Information:"
        echo "======================"
        echo "Frontend: http://${EXTERNAL_IP}"
        echo ""
        echo "You can also check status with:"
        echo "  kubectl get svc frontend-service"
        echo ""
        echo "To view logs:"
        echo "  kubectl logs -l app=frontend"
        echo "  kubectl logs -l app=backend"
        echo "  kubectl logs -l app=mysql"
        exit 0
    fi
    echo -n "."
    sleep 2
done

echo ""
echo "⚠️  LoadBalancer is still provisioning. Check status with:"
echo "  kubectl get svc frontend-service"
echo ""
echo "Once EXTERNAL-IP is assigned, access the application via that IP."

#!/bin/bash

# EKS Deployment Setup Script
# This script helps deploy the application to EKS

set -e

echo "🚀 Deploying to EKS..."

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install it first."
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

# Deploy deployment
echo "📦 Deploying deployment..."
kubectl apply -f deployment.yaml

# Wait for deployment to be ready
echo "⏳ Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=60s deployment/hello-deployment || true

# Deploy service
echo "🌐 Deploying LoadBalancer service..."
kubectl apply -f service-lb.yaml

# Wait for service to get external IP
echo "⏳ Waiting for LoadBalancer to get external IP..."
echo "This may take 1-2 minutes..."

for i in {1..30}; do
    EXTERNAL_IP=$(kubectl get svc hello-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
    if [ -n "$EXTERNAL_IP" ]; then
        echo ""
        echo "✅ Deployment complete!"
        echo "🌐 External endpoint: http://$EXTERNAL_IP"
        echo ""
        echo "You can also check status with:"
        echo "  kubectl get svc hello-service"
        exit 0
    fi
    echo -n "."
    sleep 2
done

echo ""
echo "⚠️  LoadBalancer is still provisioning. Check status with:"
echo "  kubectl get svc hello-service"
echo ""
echo "Once EXTERNAL-IP is assigned, access the application via that IP."


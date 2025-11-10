#!/bin/bash

# EKS Deployment Cleanup Script
# This script cleans up all resources deployed to EKS

set -e

echo "🧹 Cleaning up Stage 3 deployment from EKS..."

# Delete frontend LoadBalancer service
echo "🗑️  Deleting frontend LoadBalancer service..."
kubectl delete -f frontend-service-lb.yaml --ignore-not-found=true

# Delete frontend
echo "🗑️  Deleting frontend deployment..."
kubectl delete -f frontend-deployment.yaml --ignore-not-found=true

# Delete backend
echo "🗑️  Deleting backend deployment..."
kubectl delete -f backend-deployment.yaml --ignore-not-found=true

# Delete backend config
echo "🗑️  Deleting backend ConfigMap..."
kubectl delete -f backend-config.yaml --ignore-not-found=true

# Delete MySQL
echo "🗑️  Deleting MySQL deployment..."
kubectl delete -f mysql-deployment.yaml --ignore-not-found=true

# Delete MySQL config and secret
echo "🗑️  Deleting MySQL ConfigMap and Secret..."
kubectl delete -f mysql-config.yaml --ignore-not-found=true

# Wait a bit for resources to be cleaned up
echo "⏳ Waiting for resources to be cleaned up..."
sleep 5

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "Remaining resources:"
kubectl get pods
kubectl get svc
echo ""
echo "💡 Note: LoadBalancer deletion may take a few minutes to complete in AWS."


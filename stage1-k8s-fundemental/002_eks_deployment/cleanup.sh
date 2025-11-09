#!/bin/bash

# EKS Deployment Cleanup Script
# This script helps clean up the deployed resources

set -e

echo "🧹 Cleaning up EKS deployment..."

# Delete service
echo "🗑️  Deleting LoadBalancer service..."
kubectl delete -f service-lb.yaml --ignore-not-found=true

# Wait a bit for service to be deleted
sleep 5

# Delete deployment
echo "🗑️  Deleting deployment..."
kubectl delete -f deployment.yaml --ignore-not-found=true

echo "✅ Cleanup complete!"
echo ""
echo "Note: This only deletes the application resources."
echo "To delete the EKS cluster itself, run:"
echo "  eksctl delete cluster --name <cluster-name> --region <region>"


# EKS Deployment Guide

## What I Learned
- How to deploy Kubernetes applications on AWS EKS (Elastic Kubernetes Service)
- Difference between local Kubernetes (Minikube) and managed Kubernetes (EKS)
- Using LoadBalancer services in EKS to expose applications via AWS ELB
- EKS cluster setup and configuration

## Prerequisites
- AWS CLI installed and configured
- `eksctl` installed (or AWS Console access)
- `kubectl` installed
- AWS account with appropriate permissions

## Setup EKS Cluster

### Create
```bash
# Create a basic cluster with default settings
eksctl create cluster \
  --name my-eks-cluster \
  --region ap-southeast-2

# This will:
# - Create a new VPC with public/private subnets
# - Create IAM roles for EKS and node groups
# - Create a managed node group with 2 nodes (default)
# - Configure kubectl automatically
# Takes about 15-20 minutes
```


### Verify Cluster Creation

```bash
# Check cluster status
eksctl get cluster --region ap-southeast-2

# Verify kubectl connection
kubectl config get-contexts
kubectl cluster-info
kubectl get nodes

# View cluster details
aws eks describe-cluster --name my-eks-cluster --region ap-southeast-2
```

## Deploy Application

Apply deployment:
```bash
# confirm the current context
kubectl config get-contexts
kubectl apply -f deployment.yaml
kubectl get deployments
kubectl get pods
```

Apply LoadBalancer service:
```bash
kubectl apply -f service-lb.yaml
kubectl get svc
```

Wait for EXTERNAL-IP to be assigned (may take 1-2 minutes):
```bash
kubectl get svc hello-service -w
```

Access the application:
```bash
# Get the EXTERNAL-IP from kubectl get svc, a html page will be opened
curl http://<EXTERNAL-IP>
```

## Cleanup

Delete resources:
```bash
kubectl delete -f service-lb.yaml
kubectl delete -f deployment.yaml
```

Delete EKS cluster (if using eksctl):
```bash
eksctl delete cluster --name my-eks-cluster --region ap-southeast-2
```

## Useful Commands

```bash
# Check cluster status
kubectl cluster-info

# View nodes
kubectl get nodes

# View all resources
kubectl get all

# Describe service to see LoadBalancer details
kubectl describe svc hello-service

# View logs
kubectl logs -l app=hello

# Scale deployment
kubectl scale deployment hello-deployment --replicas=3
```


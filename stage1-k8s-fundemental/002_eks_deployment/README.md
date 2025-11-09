# EKS Deployment

This directory contains files for deploying a Kubernetes application on AWS EKS.

## Files
- `deployment.yaml` - Kubernetes Deployment configuration
- `service-lb.yaml` - LoadBalancer Service for EKS (creates AWS ELB)
- `notes.md` - Detailed notes and commands

## Quick Start

1. **Create EKS Cluster** (if not exists):
```bash
eksctl create cluster --name my-eks-cluster --region us-west-2 --node-type t3.medium --nodes 2
aws eks update-kubeconfig --name my-eks-cluster --region us-west-2
```

2. **Deploy Application**:
```bash
kubectl apply -f deployment.yaml
kubectl apply -f service-lb.yaml
```

3. **Get External IP**:
```bash
kubectl get svc hello-service
# Wait for EXTERNAL-IP to be assigned, then access via that IP
```

4. **Cleanup**:
```bash
kubectl delete -f service-lb.yaml
kubectl delete -f deployment.yaml
```

See `notes.md` for detailed explanations and more commands.


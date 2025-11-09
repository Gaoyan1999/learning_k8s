# Stage 3: Deploying Real Applications to EKS

Deploy a full-stack application (Vue frontend + Spring Boot backend + MySQL database) to AWS EKS.

## Architecture

- **Frontend**: Vue 3 application (LoadBalancer Service)
- **Backend**: Spring Boot REST API (ClusterIP Service) - reuses code from `../stage0-docker-basics/003_stardard_backend/`
- **Database**: MySQL 8 with persistent storage (ClusterIP Service)

## Prerequisites

- AWS account with appropriate permissions
- AWS CLI installed and configured
- `eksctl` installed
- `kubectl` installed
- Docker installed
- EKS cluster created

## Quick Start

### 1. Create EKS Cluster (if not exists)

```bash
eksctl create cluster \
  --name my-eks-cluster \
  --region us-west-2 \
  --node-type t3.medium \
  --nodes 2

aws eks update-kubeconfig --name my-eks-cluster --region us-west-2
```

### 2. Build and Push Images to ECR

```bash
chmod +x build-images.sh
export AWS_REGION=us-west-2
./build-images.sh
```

This will build and push images to ECR. Note the image URLs from the output.

### 3. Deploy to EKS

```bash
chmod +x setup.sh

# Set image URLs (from build-images.sh output)
export BACKEND_IMAGE=<your-ecr-backend-image-url>
export FRONTEND_IMAGE=<your-ecr-frontend-image-url>

# Deploy
./setup.sh
```

### 4. Access the Application

Wait for LoadBalancer to get external IP (1-2 minutes):

```bash
kubectl get svc frontend-service
```

Access via the LoadBalancer endpoint shown in the output.

### 5. Test the Application

```bash
# Get LoadBalancer endpoint
ENDPOINT=$(kubectl get svc frontend-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Create a user
curl -X POST -H "Content-Type: application/json" \
     -d '{"name":"John Doe","email":"john@example.com"}' \
     http://${ENDPOINT}/api/users

# List users
curl http://${ENDPOINT}/api/users
```

## Cleanup

```bash
chmod +x cleanup.sh
./cleanup.sh
```

## Files

- `mysql-pv.yaml`: PersistentVolumeClaim for MySQL data
- `mysql-config.yaml`: ConfigMap and Secret for MySQL
- `mysql-deployment.yaml`: MySQL deployment and service
- `backend-config.yaml`: ConfigMap for backend
- `backend-deployment.yaml`: Backend deployment and service
- `frontend-deployment.yaml`: Frontend deployment
- `frontend-service-lb.yaml`: LoadBalancer service for frontend
- `build-images.sh`: Script to build and push images to ECR
- `setup.sh`: Script to deploy everything to EKS
- `cleanup.sh`: Script to clean up resources

## Troubleshooting

### Check pod status:
```bash
kubectl get pods
kubectl logs <pod-name>
```

### Check services:
```bash
kubectl get svc
```

### Check persistent volumes:
```bash
kubectl get pvc
```

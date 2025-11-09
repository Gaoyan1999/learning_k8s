# Stage 3: Deploying Real Applications to EKS

This stage demonstrates deploying a full-stack application (Vue frontend + Spring Boot backend + MySQL database) to AWS EKS (Elastic Kubernetes Service).

## Architecture

- **Frontend**: Vue 3 application served by Nginx (LoadBalancer Service - creates AWS ELB)
- **Backend**: Spring Boot REST API (ClusterIP Service) - **reuses code from `../stage0-docker-basics/003_stardard_backend/`**
- **Database**: MySQL 8 with persistent storage using EBS (ClusterIP Service)

**Note**: The backend code is directly reused from `../stage0-docker-basics/003_stardard_backend/` directory. The Dockerfile is located in that directory, so no code duplication is needed.

## Components

### PersistentVolumes (PV) and PersistentVolumeClaims (PVC)
- `mysql-pv.yaml`: Defines a PersistentVolumeClaim for MySQL data persistence
- Uses EBS `gp3` storage class (dynamically provisioned by EKS)
- Data persists even if pods are deleted

### ConfigMap and Secret
- `mysql-config.yaml`: Contains database configuration (ConfigMap) and credentials (Secret)
- `backend-config.yaml`: Contains backend application configuration

### Deployments
- `mysql-deployment.yaml`: MySQL database with health checks and PVC
- `backend-deployment.yaml`: Spring Boot backend with liveness and readiness probes
- `frontend-deployment.yaml`: Vue frontend with health checks

### Services
- `mysql-service`: ClusterIP service for database access (internal only)
- `backend-service`: ClusterIP service for backend API (internal only)
- `frontend-service`: LoadBalancer service (creates AWS ELB for external access)

## Prerequisites

- AWS account with appropriate permissions
- AWS CLI installed and configured
- `eksctl` installed (or AWS Console access)
- `kubectl` installed
- Docker installed
- EKS cluster created and configured

## Setup Instructions

### 1. Create EKS Cluster (if not exists)

```bash
# Create a basic EKS cluster
eksctl create cluster \
  --name my-eks-cluster \
  --region us-west-2 \
  --node-type t3.medium \
  --nodes 2

# Configure kubectl to use the cluster
aws eks update-kubeconfig --name my-eks-cluster --region us-west-2

# Verify connection
kubectl cluster-info
kubectl get nodes
```

**Note**: Cluster creation takes about 15-20 minutes.

### 2. Build and Push Docker Images to ECR

The images need to be pushed to AWS ECR (Elastic Container Registry) so EKS can pull them.

**Recommended: Use the build script**:
```bash
chmod +x build-images.sh

# Set AWS region (optional, defaults to us-west-2)
export AWS_REGION=us-west-2

# Run the build script
./build-images.sh
```

This script will:
- Log in to ECR
- Create ECR repositories if they don't exist
- Build backend image from `../stage0-docker-basics/003_stardard_backend/` (reusing existing code)
- Build frontend image
- Push both images to ECR
- Display the image URLs

**Manual build** (if you prefer):

```bash
# Set variables
export AWS_REGION=us-west-2
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# Login to ECR
aws ecr get-login-password --region ${AWS_REGION} | \
  docker login --username AWS --password-stdin ${ECR_REGISTRY}

# Create repositories
aws ecr create-repository --repository-name learning-k8s-backend --region ${AWS_REGION}
aws ecr create-repository --repository-name learning-k8s-frontend --region ${AWS_REGION}

# Build and push backend
cd ../stage0-docker-basics/003_stardard_backend
docker build -t learning-k8s-backend:latest .
docker tag learning-k8s-backend:latest ${ECR_REGISTRY}/learning-k8s-backend:latest
docker push ${ECR_REGISTRY}/learning-k8s-backend:latest

# Build and push frontend
cd ../../../stage2-deployment-real-app/frontend
docker build -t learning-k8s-frontend:latest .
docker tag learning-k8s-frontend:latest ${ECR_REGISTRY}/learning-k8s-frontend:latest
docker push ${ECR_REGISTRY}/learning-k8s-frontend:latest
```

### 3. Deploy to EKS

**Recommended: Use the setup script**:
```bash
chmod +x setup.sh

# Set image URLs (from build-images.sh output)
export BACKEND_IMAGE=<your-ecr-backend-image-url>
export FRONTEND_IMAGE=<your-ecr-frontend-image-url>

# Deploy
./setup.sh
```

**Manual deployment**:

```bash
# Set image URLs
export BACKEND_IMAGE=<your-ecr-backend-image-url>
export FRONTEND_IMAGE=<your-ecr-frontend-image-url>

# 1. Create PVC for MySQL (uses EBS gp3 storage class)
envsubst < mysql-pv.yaml | kubectl apply -f -

# 2. Create ConfigMap and Secret for MySQL
kubectl apply -f mysql-config.yaml

# 3. Deploy MySQL
kubectl apply -f mysql-deployment.yaml

# 4. Wait for MySQL to be ready
kubectl wait --for=condition=ready pod -l app=mysql --timeout=120s

# 5. Create backend ConfigMap
kubectl apply -f backend-config.yaml

# 6. Deploy backend
envsubst < backend-deployment.yaml | kubectl apply -f -

# 7. Deploy frontend
envsubst < frontend-deployment.yaml | kubectl apply -f -

# 8. Deploy frontend LoadBalancer service
kubectl apply -f frontend-service-lb.yaml
```

### 4. Access the Application

Wait for the LoadBalancer to get an external IP (may take 1-2 minutes):

```bash
# Check service status
kubectl get svc frontend-service

# Get the external endpoint
kubectl get svc frontend-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

Access the application via the LoadBalancer endpoint:
```bash
# Replace with your LoadBalancer endpoint
curl http://<loadbalancer-endpoint>

# Or open in browser
open http://<loadbalancer-endpoint>
```

### 5. Test the Application

```bash
# Get the LoadBalancer endpoint
ENDPOINT=$(kubectl get svc frontend-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Create a user
curl -X POST -H "Content-Type: application/json" \
     -d '{"name":"John Doe","email":"john@example.com"}' \
     http://${ENDPOINT}/api/users

# List all users
curl http://${ENDPOINT}/api/users
```

## Key Learning Points

### PersistentVolumes (PV) and PersistentVolumeClaims (PVC)
- **PVC**: Pod's request for storage
- **Dynamic Provisioning**: EKS automatically creates PVs using EBS when PVC is created
- **Storage Class**: `gp3` is the default EBS storage class in EKS
- MySQL data persists even if pods are deleted

### ConfigMap and Secret
- **ConfigMap**: Non-sensitive configuration data
- **Secret**: Sensitive data (passwords, keys)
- Both can be injected as environment variables or mounted as files

### Health Checks
- **livenessProbe**: Determines if container is alive (restarts if fails)
- **readinessProbe**: Determines if container is ready to serve traffic
- Both are configured for MySQL, backend, and frontend

### Service Types
- **ClusterIP**: Internal service, accessible only within cluster
- **LoadBalancer**: Creates AWS ELB for external access (EKS-specific)
- **NodePort**: Not used in EKS (LoadBalancer is preferred)

### ECR (Elastic Container Registry)
- AWS-managed Docker registry
- Images must be pushed to ECR for EKS to pull them
- Automatic authentication with IAM roles

## Cleanup

```bash
chmod +x cleanup.sh
./cleanup.sh
```

Or manually:
```bash
# Delete services
kubectl delete -f frontend-service-lb.yaml
kubectl delete -f frontend-deployment.yaml
kubectl delete -f backend-deployment.yaml

# Delete MySQL
kubectl delete -f mysql-deployment.yaml

# Delete ConfigMaps and Secrets
kubectl delete -f backend-config.yaml
kubectl delete -f mysql-config.yaml

# Delete PVC (this will also delete the PV)
kubectl delete -f mysql-pv.yaml
```

**Delete EKS cluster** (if you want to remove everything):
```bash
eksctl delete cluster --name my-eks-cluster --region us-west-2
```

## Troubleshooting

### Check pod status:
```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Check services:
```bash
kubectl get svc
kubectl describe svc <service-name>
```

### Check persistent volumes:
```bash
kubectl get pv
kubectl get pvc
kubectl describe pvc mysql-pvc
```

### Check image pull errors:
```bash
# Verify images exist in ECR
aws ecr describe-images --repository-name learning-k8s-backend --region us-west-2
aws ecr describe-images --repository-name learning-k8s-frontend --region us-west-2

# Check pod events
kubectl describe pod <pod-name> | grep -A 10 Events
```

### Port forward for debugging:
```bash
# Backend
kubectl port-forward svc/backend-service 8080:8080

# MySQL
kubectl port-forward svc/mysql-service 3306:3306

# Frontend
kubectl port-forward svc/frontend-service 8080:80
```

### Common Issues

1. **Image pull errors**: Make sure images are pushed to ECR and image URLs are correct
2. **PVC not bound**: Check if storage class `gp3` is available in your EKS cluster
3. **LoadBalancer not getting IP**: Wait longer (1-2 minutes), check AWS console for ELB creation
4. **Backend can't connect to MySQL**: Check service names and ConfigMap values
5. **Frontend can't reach backend**: Check nginx proxy configuration

## Next Steps

- Add Ingress for better routing and SSL termination
- Use StatefulSet for MySQL (better for databases)
- Add resource limits and requests
- Implement proper secrets management (e.g., AWS Secrets Manager)
- Add monitoring and logging (CloudWatch, Prometheus, Grafana)
- Set up CI/CD pipeline for automated deployments

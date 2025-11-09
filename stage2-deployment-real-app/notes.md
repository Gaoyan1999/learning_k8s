# Stage 3 Deployment Notes

## Overview

This stage demonstrates deploying a full-stack application to Kubernetes with:
- **PersistentVolumes (PV)** and **PersistentVolumeClaims (PVC)** for data persistence
- **ConfigMap** and **Secret** for configuration management
- **Health checks** (livenessProbe, readinessProbe)
- **Service types** (ClusterIP for internal, NodePort for external access)

## Architecture Components

### 1. MySQL Database
- **Deployment**: Single replica MySQL 8 container
- **Storage**: Uses PV/PVC for data persistence (`/var/lib/mysql`)
- **Service**: ClusterIP (internal access only)
- **Health Checks**: Uses `mysqladmin ping` for both liveness and readiness
- **Configuration**: Database name from ConfigMap, credentials from Secret

### 2. Spring Boot Backend
- **Deployment**: 2 replicas for high availability
- **Service**: ClusterIP (internal access only)
- **Health Checks**: 
  - Uses `/api/users` endpoint (GET request)
  - Liveness: checks every 10s after 60s initial delay
  - Readiness: checks every 5s after 30s initial delay
- **Configuration**: 
  - Database URL from ConfigMap
  - Credentials from Secret
  - Port from ConfigMap

### 3. Vue Frontend
- **Deployment**: Single replica (can be scaled)
- **Service**: NodePort (external access on port 30080)
- **Health Checks**: Uses root path `/` for both liveness and readiness
- **Proxy**: Nginx configuration proxies `/api` requests to backend-service

## Key Concepts Learned

### PersistentVolumes (PV) and PersistentVolumeClaims (PVC)

**PersistentVolume (PV)**:
- Cluster-level storage resource
- Can be provisioned statically or dynamically
- In this example, uses `hostPath` for local development
- Production should use proper storage classes (e.g., AWS EBS, GCE Persistent Disk)

**PersistentVolumeClaim (PVC)**:
- Pod's request for storage
- Binds to a PV that matches the requirements
- Pods reference the PVC, not the PV directly

**Example**:
```yaml
# PV defines available storage
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /tmp/mysql-data

# PVC requests storage
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
spec:
  resources:
    requests:
      storage: 5Gi
  accessModes:
    - ReadWriteOnce
```

### ConfigMap and Secret

**ConfigMap**:
- Stores non-sensitive configuration data
- Can be injected as environment variables or mounted as files
- Used for database host, port, application settings

**Secret**:
- Stores sensitive data (passwords, keys, tokens)
- Base64 encoded (but not encrypted by default)
- Used for database credentials

**Example**:
```yaml
# ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
data:
  database: "demo_db"
  host: "mysql-service"

# Secret
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
type: Opaque
stringData:
  root-password: "root"
  username: "root"
```

### Health Checks

**Liveness Probe**:
- Determines if container is alive
- If fails, Kubernetes restarts the container
- Example: MySQL uses `mysqladmin ping`

**Readiness Probe**:
- Determines if container is ready to serve traffic
- If fails, container is removed from Service endpoints
- Example: Backend checks `/api/users` endpoint

**Configuration**:
```yaml
livenessProbe:
  httpGet:
    path: /api/users
    port: 8080
  initialDelaySeconds: 60
  periodSeconds: 10
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /api/users
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 5
  failureThreshold: 3
```

### Service Types

**ClusterIP** (default):
- Internal service, accessible only within cluster
- Used for backend and database communication
- Example: `backend-service`, `mysql-service`

**NodePort**:
- Exposes service on each node's IP at a static port
- Accessible from outside cluster
- Port range: 30000-32767
- Example: `frontend-service` on port 30080

**LoadBalancer**:
- External IP provided by cloud provider
- Not used in this example (local cluster)

## Deployment Order

1. **PV/PVC**: Create storage first
2. **ConfigMap/Secret**: Create configuration
3. **MySQL**: Deploy database and wait for readiness
4. **Backend**: Deploy backend (depends on MySQL)
5. **Frontend**: Deploy frontend (depends on backend)

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
kubectl describe pv mysql-pv
kubectl describe pvc mysql-pvc
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

1. **MySQL not ready**: Wait longer, check logs
2. **Backend can't connect to MySQL**: Check service name and ConfigMap
3. **Frontend can't reach backend**: Check nginx proxy configuration
4. **PVC not bound**: Check PV exists and matches requirements

## Optional: Using Spring Boot Actuator

For better health checks, you can add Spring Boot Actuator to the backend:

1. Add to `build.gradle`:
```gradle
implementation 'org.springframework.boot:spring-boot-starter-actuator'
```

2. Update `application.yml`:
```yaml
management:
  endpoints:
    web:
      exposure:
        include: health
  endpoint:
    health:
      show-details: always
```

3. Update health check paths in `backend-deployment.yaml`:
```yaml
path: /actuator/health
```

## Next Steps

- Add Ingress for better external access
- Use StatefulSet for MySQL (better for databases)
- Add resource limits and requests
- Implement proper secrets management (e.g., sealed-secrets, external-secrets)
- Add monitoring and logging (Prometheus, Grafana, ELK)


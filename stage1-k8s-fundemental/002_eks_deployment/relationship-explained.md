# Relationship: Cluster, Node, Deployment, Service, Pods

## Overview

Understanding the hierarchy and relationships between these Kubernetes concepts is crucial for working with EKS.

```
Cluster (EKS)
  └── Nodes (EC2 instances)
      └── Pods (containers)
          └── Managed by Deployment
              └── Exposed by Service
```

## Detailed Relationships

### 1. Cluster

**What it is:**
- A **Cluster** is the top-level container that includes everything
- In EKS, the cluster is managed by AWS (Control Plane)
- Contains one or more Nodes

**Analogy:** Think of it as a **data center** or **cloud infrastructure**

**In EKS:**
- The EKS cluster is the Kubernetes control plane managed by AWS
- You create it once: `eksctl create cluster --name my-cluster`
- Cost: ~$0.10/hour (~$73/month) for the control plane

### 2. Node

**What it is:**
- A **Node** is a worker machine (EC2 instance in EKS) that runs your applications
- Nodes are where Pods actually run
- A cluster contains multiple nodes for high availability

**Analogy:** Think of it as a **physical server** or **computer** in the data center

**In EKS:**
- Nodes are EC2 instances (e.g., t3.medium)
- Managed by Node Groups
- You can have 1 to hundreds of nodes
- Cost: Depends on instance type (e.g., t3.medium ~$30/month per node)

**Relationship:**
- Cluster **contains** Nodes
- Multiple Nodes provide redundancy and scalability

### 3. Pods

**What it is:**
- A **Pod** is the smallest deployable unit in Kubernetes
- Usually contains one container (but can have multiple tightly coupled containers)
- Pods run on Nodes
- Pods have their own IP address (internal to cluster)

**Analogy:** Think of it as a **box** or **package** containing your application

**In EKS:**
- Pods are scheduled on Nodes by Kubernetes
- If a Node fails, Pods are rescheduled to other Nodes
- Pod IPs are ephemeral (change when Pod restarts)

**Relationship:**
- Nodes **host** Pods
- Multiple Pods can run on one Node
- Pods are the actual running instances of your application

### 4. Deployment

**What it is:**
- A **Deployment** is a higher-level abstraction that manages Pods
- Ensures a specified number of Pod replicas are running
- Handles Pod creation, updates, and scaling
- Provides rolling updates and rollback capabilities

**Analogy:** Think of it as a **blueprint** or **template** that says "I want 3 copies of this application running"

**In EKS:**
- You define a Deployment with YAML
- Deployment creates and manages Pods
- If a Pod crashes, Deployment automatically creates a new one
- You can scale by changing replica count

**Relationship:**
- Deployment **manages** Pods
- Deployment creates Pods based on template
- Deployment ensures desired number of Pods are running
- Pods are **owned** by Deployment

### 5. Service

**What it is:**
- A **Service** provides a stable network endpoint to access Pods
- Gives Pods a permanent IP address and DNS name
- Load balances traffic across multiple Pods
- Abstracts away Pod IP changes

**Analogy:** Think of it as a **phone number** or **company switchboard** that routes calls to available employees

**In EKS:**
- Service types: ClusterIP (internal), NodePort, LoadBalancer (creates AWS ELB)
- Service selects Pods using labels
- Service IP stays constant even when Pods restart

**Relationship:**
- Service **exposes** Pods managed by Deployment
- Service routes traffic to Pods
- Service provides stable access point (Pods can come and go)

## Complete Relationship Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    EKS Cluster                              │
│  (Managed by AWS - Control Plane)                           │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Node Group                               │  │
│  │                                                       │  │
│  │  ┌──────────────┐      ┌──────────────┐               │  │
│  │  │   Node 1     │      │   Node 2     │               │  │
│  │  │ (EC2 t3.med) │      │ (EC2 t3.med) │            │   │
│  │  │              │      │              │            │   │
│  │  │  ┌────────┐ │      │  ┌────────┐   │            │   │
│  │  │  │ Pod A  │ │      │  │ Pod C  │   │            │   │
│  │  │  │(nginx) │ │      │  │(nginx) │   │            │   │
│  │  │  └────────┘ │      │  └────────┘   │            │   │
│  │  │             │      │              │            │   │
│  │  │  ┌────────┐ │      │              │            │   │
│  │  │  │ Pod B  │ │      │              │            │   │
│  │  │  │(nginx) │ │       │              │            │   │
│  │  │  └────────┘ │      │              │            │   │
│  │  └──────────────┘      └──────────────┘             │   │
│  │         ▲                      ▲                    │   │
│  │         │                      │                    │   │
│  │         └──────────┬───────────┘                    │   │
│  │                    │                                │   │
│  │         ┌──────────▼───────────┐                    │   │
│  │         │   Deployment         │                    │   │
│  │         │   (replicas: 3)      │                    │   │
│  │         │   Manages Pods       │                    │   │
│  │         └──────────────────────┘                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                            │
│         ┌──────────────────────────────────────┐           │
│         │         Service (LoadBalancer)       │           │
│         │    hello-service:80                  │           │
│         │    EXTERNAL-IP: x.x.x.x              │           │
│         │    Routes to: Pod A, B, C            │           │
│         └──────────────────────────────────────┘           │
│                    ▲                                       │
│                    │                                       │
│         ┌──────────┴──────────┐                            │
│         │   Internet/Users    │                            │
│         └─────────────────────┘                            │
└────────────────────────────────────────────────────────────┘
```

## Real-World Example Flow

### Step 1: Create Cluster
```bash
eksctl create cluster --name my-cluster --region ap-southeast-2
```
**Result:** EKS cluster created with Control Plane (managed by AWS)

### Step 2: Cluster Creates Nodes
```bash
# eksctl automatically creates node group with 2 nodes
```
**Result:** 2 EC2 instances (Nodes) are created and join the cluster

### Step 3: Deploy Application
```bash
kubectl apply -f deployment.yaml
```
**deployment.yaml:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-deployment
spec:
  replicas: 3  # Want 3 Pods
  selector:
    matchLabels:
      app: hello
  template:
    spec:
      containers:
      - name: nginx
        image: nginx:latest
```

**What happens:**
1. Deployment is created
2. Deployment creates 3 Pods (replicas: 3)
3. Kubernetes scheduler places Pods on available Nodes
4. Pods start running containers

**Result:**
- 3 Pods running (e.g., 2 on Node 1, 1 on Node 2)
- Each Pod has its own internal IP (e.g., 10.244.0.5, 10.244.0.6, 10.244.1.7)

### Step 4: Expose with Service
```bash
kubectl apply -f service-lb.yaml
```
**service-lb.yaml:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-service
spec:
  type: LoadBalancer
  selector:
    app: hello  # Matches Pods with label app=hello
  ports:
  - port: 80
    targetPort: 80
```

**What happens:**
1. Service is created
2. Service finds all Pods with label `app=hello`
3. Service creates AWS Load Balancer (in EKS)
4. Service gets external IP address
5. Traffic to Service is load-balanced to all matching Pods

**Result:**
- Service has stable IP: `hello-service`
- External IP: `x.x.x.x` (from AWS ELB)
- Traffic to `x.x.x.x:80` is distributed to Pod A, B, C

## Key Relationships Summary

| Relationship | Description |
|-------------|-------------|
| **Cluster → Node** | Cluster contains Nodes. One cluster can have many nodes. |
| **Node → Pod** | Nodes host Pods. One node can run many pods. |
| **Deployment → Pod** | Deployment manages Pods. Deployment creates, updates, and ensures Pods are running. |
| **Service → Pod** | Service exposes Pods. Service provides stable access to Pods managed by Deployment. |
| **Service → Deployment** | Service selects Pods by labels that match Deployment's Pod template. |

## Lifecycle Example

### When Pod Crashes:

1. **Pod crashes** (container exits)
2. **Deployment detects** Pod is not running
3. **Deployment creates** new Pod to replace it
4. **New Pod gets** new IP address
5. **Service automatically** updates to route to new Pod
6. **Users don't notice** - Service IP stays the same

### When Scaling:

```bash
kubectl scale deployment hello-deployment --replicas=5
```

1. **Deployment creates** 2 more Pods (now 5 total)
2. **Pods are scheduled** on available Nodes
3. **Service automatically** includes new Pods in load balancing
4. **Traffic is distributed** across all 5 Pods

### When Node Fails:

1. **Node fails** (EC2 instance terminates)
2. **Kubernetes detects** Node is down
3. **Pods on that Node** are marked as failed
4. **Deployment creates** new Pods on remaining healthy Nodes
5. **Service continues** routing to healthy Pods
6. **Application stays** available (if enough nodes remain)

## Commands to See Relationships

```bash
# See cluster info
kubectl cluster-info

# See all nodes in cluster
kubectl get nodes

# See all pods (running on nodes)
kubectl get pods -o wide  # Shows which node each pod is on

# See deployments (managing pods)
kubectl get deployments

# See services (exposing pods)
kubectl get services

# See relationship: which pods are managed by deployment
kubectl get pods -l app=hello

# See relationship: which pods are selected by service
kubectl get endpoints hello-service

# Describe to see full relationships
kubectl describe deployment hello-deployment
kubectl describe service hello-service
kubectl describe pod <pod-name>
```

## Visual Summary

```
User Request
    ↓
Service (stable IP: hello-service)
    ↓ (load balances)
Pods (Pod A, Pod B, Pod C) ← managed by Deployment
    ↓ (running on)
Nodes (Node 1, Node 2) ← part of
Cluster (EKS)
```

## Key Takeaways

1. **Cluster** is the top level - contains everything
2. **Nodes** are the workers - where Pods run
3. **Pods** are the actual applications - smallest unit
4. **Deployment** manages Pods - ensures they're running
5. **Service** exposes Pods - provides stable access

**Remember:** 
- You deploy a **Deployment** (not Pods directly)
- Deployment creates **Pods**
- Pods run on **Nodes**
- **Service** makes Pods accessible
- All of this is in a **Cluster**


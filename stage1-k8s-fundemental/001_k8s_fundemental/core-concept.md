# Core Block
| Concept                | Description                                               | Analogy                                         |
| ---------------------- | --------------------------------------------------------- | ----------------------------------------------- |
| **Cluster**            | A set of machines (nodes) managed by Kubernetes           | A data center managed by K8S                    |
| **Node**               | A worker machine (VM or EC2) that runs containers         | A single computer                               |
| **Pod**                | The smallest deployable unit — usually runs one container | A “box” holding your app                        |
| **ReplicaSet**         | Ensures a specific number of Pods are running             | A supervisor keeping N boxes alive              |
| **Deployment**         | Manages ReplicaSets and Pod updates                       | The “blueprint” for rolling updates             |
| **Service**            | Gives Pods a stable network name & IP                     | A company phone number that forwards to workers |
| **ConfigMap / Secret** | Store configuration and sensitive info                    | Environment variables / passwords               |
| **Namespace**          | Logical separation inside a cluster                       | Folders for different teams/projects            |
| **Control Plane**      | Brains of the cluster (API Server, Scheduler, etc.)       | The management office                           |


# Architecture
[Kubernetes Cluster]
   ├── Control Plane
   │     ├── API Server
   │     ├── Scheduler
   │     ├── Controller Manager
   │     └── etcd (stores cluster state)
   │
   └── Worker Nodes
         ├── kubelet (runs pods)
         ├── container runtime (Docker/Containerd)
         └── Pods (your applications)

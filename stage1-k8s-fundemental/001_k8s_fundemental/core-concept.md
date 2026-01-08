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


# Concept

## Pods
A Pod is a group of one or more application containers (such as Docker) and includes shared storage (volumes), IP address and information about how to run them.

The containers in a Pod share an IP Address and port space, are always co-located and co-scheduled, and run in a shared context on the same Node, just like runs in a same machine.


## Nodes
A Pod always runs on a Node. A node can run more than one pods. A node is a worker in K8S managed by **control plane**

Every Node runs at least: **kubelet** and **container runtime(Docker)**

## Services
A Kubernetes Service is an abstraction layer which defines a logical set of Pods and enables external traffic exposure, load balancing and service discovery for those Pods.

Services can be exposed in different ways by specifying a type in the spec of the Service:
- Cluster IP(dafault): make the Service only reachable from within the cluster. Suitable for backend services.

- NodePort: expose by node

- LoadBalancer: creates an external load balancer and assigns a fixed, external IP the Service.

- ExternalName

## Services and Labels
Services match a set of Pods using labels and selectors. Labels are key/value pairs attached to the objects
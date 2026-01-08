# Using Minikube to Create a Cluster

## Objective
- Learn what a Kubernetes cluster is.
- Learn what Minikube is.
- Start a Kubernetes cluster on your computer.



## K8S Cluster

A K8S cluster consists of two types of resources:

1. **Control Plane**: coordinating the cluster

    It's responsible for managing the cluster.

2. **Nodes**: workers running actual applications

    A node is a VM or a physical computer that are used to host the running applications and serve as a worker machine in K8S cluster.

    **Kubelet**: An agent for managing the node and communicating with the control palne via **K8S API**. Each node has a kubelet




## Deploy with minikube

1. [Install minikube](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Farm64%2Fstable%2Fbinary+download)


2. Setup minikube and running a dashboard

    ```shell
    minikube start
    minikube dashboard
    ```


3. Create a Deployment

    creating a deployment with `kubectl create`

    ```shell
    # Run a test container image that includes a webserver
    kubectl create deployment hello-node --image=registry.k8s.io/e2e-test-images/agnhost:2.53 -- /agnhost netexec --http-port=8080
    ```

    check it by command or web dashboard
    ```shell
    kubectl get deployments
    ```

    check pods log
    ```
    kubectl logs hello-node-5f76cf6ccf-br9b5
    ```

4. Create a Service

    By default, a Pod can only be accessed by its internal IP within the cluster. If you want to access it from the outside, you have to expose the Pod as a K8S `Service`

    Expose the Pod to the public internet using the `kubectl expose` command:
    It only declares a Service object but doesn't bind the port.
    ```
    kubectl expose deployment hello-node --type=LoadBalancer --port=8080
    ```

    check the servies
    ```
    kubectl get services
    ```

    setup
    ```
    minikube service hello-node
    ```

5. Clean up
    clean cluster
    ```
    kubectl delete service hello-node
    kubectl delete deployment hello-node
    ```

    stop minikube
    ```
    minikube stop
    ```
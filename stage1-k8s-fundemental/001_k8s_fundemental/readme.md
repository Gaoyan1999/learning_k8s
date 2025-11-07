# Pods
Apply it:
```
kubectl apply -f pod.yaml
```

Check:
```
kubectl get pods
kubectl describe pod hello-pod
```

Then access it temporarily:
```
kubectl port-forward pod/hello-pod 8080:80
```

Visit http://localhost:8080
 → you’ll see the NGINX default page 🎉

Delete:
 ```
 kubectl delete hello-pod
 ```

# Deployment
### Difference between Pods
A **Pod** is the smallest deployable unit and usually runs a single instance of an application (a single container or a tightly coupled set of containers). If a Pod fails, it is **not** automatically recreated.

A **Deployment** is a higher-level object that manages Pods for you. It ensures the specified number of Pods are always running, automatically replaces failed Pods, supports rolling updates, and makes it easier to scale or update your application. In short: Deployments manage the lifecycle and scaling of your Pods.


### Run

Apply
```
kubectl apply -f deployment.yaml
kubectl get deployments
kubectl get pods -l app=hello
```

Delete
```
kubectl delete deployment hello
kubectl get deployments
```

# Service
### Difference between Deployment
A **Deployment** manages sets of Pods, but those Pods get random, internal IPs inside the Kubernetes cluster, which can change over time. This makes it difficult for clients (or even other Pods) to reliably access them.

A **Service** provides a permanent, stable network endpoint to access the Pods managed by a Deployment. It automatically routes traffic to healthy Pods, balances the load between them, and ensures clients don’t need to track Pod IP changes. In essence: Deployments manage Pod lifecycles; Services expose access to those Pods in a reliable way.

```
                +----------------------+
                |     Service (VIP)    |  <- stable entry point
                |   hello-service:80   |
                +----------+-----------+
                           |
         +-----------------+----------------+
         |                                  |
+------------------+              +------------------+
| Pod A (nginx)    |              | Pod B (nginx)    |
| 10.244.0.5:80    |              | 10.244.1.7:80    |
+------------------+              +------------------+
         ^                                  ^
         |                                  |
    created and managed by          created and managed by
       +------------------------------------------+
       |           Deployment: hello              |
       +------------------------------------------+

```


### Run
Apply:
```
kubectl apply -f service.yaml
kubectl get svc
```

If you’re running Minikube (failure):
```
minikube service hello-service
```

If you’re on EKS, use:
```
kubectl port-forward svc/hello-service 8080:80
```
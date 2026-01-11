# Exposing an External IP Address to Access an Application in a Cluster

### Setup Deployment
Setup five Hello world applications

```shell
kubectl apply -f ./load-balancer-exmaple.yaml
```

Create a Service object that exposes the deployment:
```shell
kubectl expose deployment hello-world --type=LoadBalancer --name=my-service
kubectl describe services/my-service
```

```shell
Name:                     my-service
Namespace:                default
Labels:                   app.kubernetes.io/name=load-balancer-example
Annotations:              <none>
Selector:                 app.kubernetes.io/name=load-balancer-example
Type:                     LoadBalancer
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.99.86.121
IPs:                      10.99.86.121
Port:                     <unset>  8080/TCP
TargetPort:               8080/TCP
NodePort:                 <unset>  31529/TCP
Endpoints:                10.244.0.48:8080,10.244.0.46:8080,10.244.0.47:8080 + 2 more...
Session Affinity:         None
External Traffic Policy:  Cluster
Internal Traffic Policy:  Cluster
Events:                   <none>
```



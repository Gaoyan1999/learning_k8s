# Connecting Applications with Services

setup
```shell
kubectl apply -f ./run-my-nginx.yaml
```
check IP
```shell
kubectl get pods -l run=my-nginx -o custom-columns=POD_IP:.status.podIPs
POD_IP
[map[ip:10.244.0.85]]
[map[ip:10.244.0.86]]
```

create service
```shell
kubectl expose deployment/my-nginx
```

same with `kubectl apply -f`
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-nginx
  labels:
    run: my-nginx
spec:
  ports:
  - port: 80
    protocol: TCP
  selector:
    run: my-nginx
```

Check the related endpoints of `my-nginx`
```shell
kubectl get endpointslices -l kubernetes.io/service-name=my-nginx
NAME             ADDRESSTYPE   PORTS   ENDPOINTS                 AGE
my-nginx-bkhfp   IPv4          80      10.244.0.86,10.244.0.85   2m34s
```

## Accessing the service

When a Pod starts, kubelet injects environment variables for **Services that already exist at that time**, such as `MY_SERVICE_SERVICE_HOST` and `MY_SERVICE_SERVICE_PORT`.  
This happens **only once at Pod startup**.

If the Pod is created **before** the Service, these environment variables will be missing and **will not be added later**, even after the Service is created. Kubernetes itself will still work, but applications that rely on these variables may fail.

For this reason, a Service should be created **before** its Pods. In modern Kubernetes, it is recommended to access Services via **DNS** (for example, `my-service.default.svc.cluster.local`), which is not affected by creation order.


## DNS

Kubernetes offers a DNS cluster addon Service that automatically assigns dns names to other Services. 

```shell
kubectl get services kube-dns --namespace=kube-system
```

```shell
kubectl run -i --tty --image busybox:1.28 dns-test --restart=Never --rm

nslookup my-nginx
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      my-nginx
Address 1: 10.102.223.186 my-nginx.default.svc.cluster.local
```

## Securing the service

TBD
# StatefulSet Basics

## Creating a StatefulSet

create a statefulSet and Service

```shell
kubectl apply -f ./web.yaml 

# check
kubectl get statefulset
kubectl get service
```

Ordered Pod Creation. The `web-1` Pod is not lauched until the `web-0` Pod is Running.
```shell
kubectl get pods --watch -l app=nginx

NAME    READY   STATUS    RESTARTS   AGE
web-0   0/1     Pending   0          0s
web-0   0/1     Pending   0          0s
web-0   0/1     ContainerCreating   0          0s
web-0   1/1     Running             0          2s
web-1   0/1     Pending             0          0s
web-1   0/1     Pending             0          0s
web-1   0/1     ContainerCreating   0          0s
web-1   1/1     Running             0          1s
```
## Pods in a StatefulSet
Pods in a StatefulSet have a unqiue ordinal index and a stabe network identity. `<statefulset name>-<ordinal index>`


Examine their in-cluster DNS addresses
```shell
kubectl run -i --tty --image busybox:1.28 dns-test --restart=Never --rm
```

```shell
# Run this in the dns-test container shell
nslookup web-0.nginx
# Ouptut
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      web-0.nginx
Address 1: 10.244.0.64 web-0.nginx.default.svc.cluster.local
```

Writing to stable storage
The StatefulSet controller created two PersistentVolumeClaims that are bound to two PersistentVolumes.
```shell
kubectl get pvc

# output
NAME        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
www-web-0   Bound    pvc-4b7ed62f-9ad0-4455-b25b-ad038198b244   1Gi        RWO            standard       <unset>                 73m
www-web-1   Bound    pvc-0ba8b32c-a1eb-4891-b458-c78a03f0a222   1Gi        RWO            standard       <unset>                 46m
```

Write hostname to `index.html`
```shell
for i in 0 1; do kubectl exec web-$i -- chmod 755 /usr/share/nginx/html; done

for i in 0 1; do kubectl exec "web-$i" -- sh -c 'echo "$(hostname)" > /usr/share/nginx/html/index.html'; done

for i in 0 1; do
  kubectl exec -it web-$i -- curl http://localhost/
done
```

## Scaling a statefulSet

each Pods sequentially with respect to its ordinal index, w
```shell
kubectl scale sts web --replicas=5
```

Scaling down
```shell
kubectl patch sts web -p '{"spec":{"replicas":3}}'
```

Get the PVC, notice that still five PVC and persisitentVolumes.
```shell
kubectl get pvc -l app=nginx
```

## Updating StatefulSets




## Clean up
```shell
kubectl delete statefulset web
kubectl delete svc nginx
kubectl delete pvc www-web-0 www-web-1 www-web-2 www-web-3 www-web-4
```


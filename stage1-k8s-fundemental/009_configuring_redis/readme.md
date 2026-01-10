# Configuring Redis using a ConfigMap

A real world example of how to configure Redis using a configMap

Apply Redis Configmap and Pods

```shell
kubectl apply -f ./example-redis-config.yaml
kubectl apply -f ./redis-pod.yaml
```

check `exmaple-redis-config`, there is an empty `redis-config` key

```shell
kubectl describe configmap/example-redis-config
```

```shell
Name:         example-redis-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
redis-config:
----



BinaryData
====

Events:  <none>
```

Enter the pods and run `redis-cli` to check config
```shell
kubectl exec -it pod/redis -- redis-cli
```
Check config
```shell
127.0.0.1:6379> CONFIG GET maxmemory
127.0.0.1:6379> CONFIG GET maxmemory-policy
```

Now, update the redis-config in yaml and reapply.
```shell
...
data:
  redis-config: |
    maxmemory 2mb
    maxmemory-policy allkeys-lru    
```
```
kubectl apply -f example-redis-config.yaml
kubectl describe configmap/example-redis-config
```

However, when I enter the redis Pod, the config remains unchanged. Because the Pod needs to be restarted to grab the lastest updated value.

```shell
kubectl delete pod redis
kubectl apply -f ./example-redis-config.yaml
```
Check again, notice the config has been updated.
```shell
kubectl exec -it pod/redis -- redis-cli
# redis-cli
127.0.0.1:6379> config get maxmemory
```

Finally, Clean up the work
```shell
kubectl delete pod/redis configmap/example-redis-config
```

# Share a Cluster with Namespaces

## Basic command
Check

```shell
kubectl get ns
```

Creating a new namespace

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: <insert-namespace-name-here>
```

```shell
kubectl create -f ./my-namespace.yaml
```

switch namespace
```shell
kubectl config set-context --current --namespace=<name>
```

## Subdiving your cluster using k8s namespaces

Create the `development` and `production` namespace
```shell
kubectl create -f https://k8s.io/examples/admin/namespace-dev.json
kubectl create -f https://k8s.io/examples/admin/namespace-prod.json
```

Create pods in each namespace
```shell
kubectl create deployment snowflake \
  --image=registry.k8s.io/serve_hostname \
  -n=development --replicas=2
```

Switch to `development` namespace, and check
```shell
kubectl config set-context --current --namespace=development
kubectl get pods
# OR
kubectl get pods -n=development
```

Do the same things for `production`

```shell
kubectl create deployment cattle --image=registry.k8s.io/serve_hostname -n=production
kubectl scale deployment cattle --replicas=5 -n=production

kubectl get deployment -n=production
```



## Motivation for using namespaces

It helps different groups, teams, or customers to share one k8s cluster.


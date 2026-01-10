# Apply Pod Security Standards at the Cluster Level

## Choose the right Pod Security Standard to apply

1. Create a cluster with no Pod Security Standards first

```shell
kind create cluster --name psa-wo-cluster-pss
```

2. Set the kubectl context to the new cluster
```shell
kubectl cluster-info --context kind-psa-wo-cluster-pss
```

3. get a list of ns in the cluster
```shell
kubectl get ns
```

4. Use `--dry-run=server` to understand what happens when different Pod Security Standards are applied:


```shell
kubectl label --dry-run=server --overwrite ns --all pod-security.kubernetes.io/enforce=privileged

kubectl label --dry-run=server --overwrite ns --all \
pod-security.kubernetes.io/enforce=baseline

kubectl label --dry-run=server --overwrite ns --all \
pod-security.kubernetes.io/enforce=restricted
```

5. Clean up
```shell
kind delete cluster --name psa-with-cluster-pss
```
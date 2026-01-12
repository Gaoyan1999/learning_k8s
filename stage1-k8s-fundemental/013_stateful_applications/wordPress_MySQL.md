# Example: Deploying WordPress and MySQL with Persistent Volumes

## Apply and Verify

```shell
kubectl apply -k ./
```

verify secrets and pvc
```shell
kubectl get secrets
kubectl get pvc

minikube service wordpress --url
```

## Cleaning up

```shell
kubectl delete -k ./
```
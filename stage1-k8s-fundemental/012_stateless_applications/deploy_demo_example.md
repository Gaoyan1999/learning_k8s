# Example: Deployment PHP Guestbook application with Redis

## Start up Redis

create deployment and service
```shell
kubectl apply -f ./redis-leader-deployment.yaml
kubectl logs -f  deployment/redis-leader
kubectl apply -f ./redis-leader-service.yaml   

kubectl apply -f ./redis-follower-deployment.yaml
kubectl apply -f ./redis-follower-service.yaml   
```
Then, we have one leader and two followers


## Setup up Frontend

```shell
kubectl apply -f ./frontend-deployment.yaml 
kubectl apply -f ./frontend-service.yaml
```

1. Viewing the Frontend Service via port-forward.

    Forward port `8080` on local machine to port `80` on the service

    ```shell
    kubectl port-forward svc/frontend 8080:80
    ```

2. Viewing the Frontend Service via LoadBalancer
    change the type to `LoadBalancer ` in `frontend-service.yaml` 
    ```shell
    minikube tunnel
    kubectl get svc frontend
    ```
## Scale the Frontend

```shell
kubectl scale deployment frontend --replicas=5
```

## Cleaning up

```shell
kubectl delete deployment -l app=redis
kubectl delete service -l app=redis
kubectl delete deployment frontend
kubectl delete service frontend
```
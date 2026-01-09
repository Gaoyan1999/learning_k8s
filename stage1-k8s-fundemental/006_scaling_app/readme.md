# Running Multiple Instances of Your App

## Setup: create deployment and service
```
kubectl create deployment kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1

kubectl expose deployment/kubernetes-bootcamp --type="LoadBalancer" --port 8080
```

## Scaling a Deployment

See ReplicaSet
```
kubectl get rs
```

Scale the Deployment to 4 replicas
```
kubectl scale deployments/kubernetes-bootcamp --replicas=4
```

There are 4 instances (pods) with different IP addresses
```
kubectl get pods -o wide
```

## Scaling Down
same command
```
kubectl scale deployments/kubernetes-bootcamp --replicas=2
```
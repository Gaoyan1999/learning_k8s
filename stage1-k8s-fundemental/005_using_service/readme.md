# Using a Service to Expose Your App

## Step 1: Creating a new Service

create deployment
```
kubectl create deployment kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1
```

expose it with NodePort and check status
```
kubectl expose deployment/kubernetes-bootcamp --type="NodePort" --port 8080

kubectl describe services/kubernetes-bootcamp
```

setup
```
minikube service kubernetes-bootcamp --url
```

## Step 2: Using labels
query by `-l`
```
kubectl get pods -l app=kubernetes-bootcamp
kubectl get services -l app=kubernetes-bootcamp
```

Add a new label for pods and query it
```
kubectl label pods "$POD_NAME" version=v1

kubectl get pods -l version=v1
```

## Step3: Deleting a service
kubectl delete service -l app=kubernetes-bootcamp
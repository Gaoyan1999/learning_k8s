# Using kubectl to Create a Deployment  [link](https://kubernetes.io/docs/tutorials/kubernetes-basics/deploy-app/deploy-intro/)

## Deploy an app
``` 
kubectl create deployment kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1
```

## View the app
open a second terminal and run
```
kubectl proxy
```

proxy can create a proxy that will forward communications into the cluster-wide, private network. 


Get Pod_Name end executing commands on the container
```
export POD_NAME="$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')"
echo Name of the Pod: $POD_NAME
```

```
kubectl exec -ti $POD_NAME -- bash
```
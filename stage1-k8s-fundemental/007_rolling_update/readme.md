# Perform a rolling Update

Origin images
```shell
kubectl create deployment kubernetes-bootcamp --image=gcr.io/
```

To update the image of the application to version 2, use the `set image `subcommand

```shell
kubectl set image deployments/kubernetes-bootcamp kubernetes-bootcamp=docker.io/jocatalin/kubernetes-bootcamp:v2
```

check the progress of deployment and wait util it finishes
```shell
kubectl rollout status deployments/kubernetes-bootcamp
```

## Rollback

try to pull an image with a tag not existing. The pod status would be `ImagePullBackOff`
```shell
kubectl set image deployments/kubernetes-bootcamp kubernetes-bootcamp=gcr.io/google-samples/kubernetes-bootcamp:v10
```

roll back deployment to the last working version
```shell
kubectl rollout undo deployments/kubernetes-bootcamp
```

## Clean Up

```shell
kubectl delete deployments/kubernetes-bootcamp services/kubernetes-bootcamp
```

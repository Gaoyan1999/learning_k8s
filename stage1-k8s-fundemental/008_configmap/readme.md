# Updating Configuration via a ConfigMap [link](https://kubernetes.io/docs/tutorials/configuration/updating-configuration-via-a-configmap/)

## Update configuration via a ConfigMap mounted as a Volume

Creating a configmap naming **sport**, `--from-literal` means reading key value pair through terminal
```shell
kubectl create configmap sport --from-literal=sport=football
```
It equals to below yaml

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: sport
data:
  sport: football
```

`./deployment-with-configmap-as-volume.yaml` is an example of a Deployment manifest with the ConfigMap sport mounted as a volume into the Pod's only container.

create deployment and check pods
```shell
kubectl apply -f ./deployment-with-configmap-as-volume.yaml
kubectl get pods -l app.kubernetes.io/name=configmap-volume
```

Edit config map, change the sport to **cricket**
```shell
kubectl edit configmap sport
```

After few seconds, the change is applied to pods
```shell
kubectl logs deployments/configmap-volume --follow
```
When a ConfigMap mapped into a running Pod using a configMap, and you update that ConfigMap, the running Pod sees the update almost immediately.
However, application only sees the change if it is written to either poll for changes, or watch for file updates.
An application that loads its configuration once at startup will not notice a change.

## Update environment variables of a Pod via ConfigMap

Create a configmap
```shell
kubectl create configmap fruits --from-literal=fruits=apples
```

Create a Deployment by `./deployment-with-configmap-as-envvar.yaml`

```shell
kubectl apply -f ./deployment-with-configmap-as-envvar.yaml
```

Edit the configmap, changing to mangoes. 
```shell
kubectl edit configmap fruits
```
check the log, notice that the output remains unchanged. This is because env varibles running inside a Pod are not updated when source data changes. 

```shell
kubectl logs deployments/configmap-env-var --follow
```

We need force update, let k8s replacing existing Pods
```shell
kubectl rollout restart deployment configmap-env-var
```

## Update configuration via a ConfigMap in a multi-container Pod

In this demo. K8S sets up three Pods. For each pod, there are two containers, alpine and nginx. Alpine read configmap and write the color information to `/pod-data`

Create config
```shell
kubectl create configmap color --from-literal=color=red
```

Apply deplpyment
```shell
kubectl apply -f ./deployment-with-configmap-two-containers.yaml
```

Expose the Deployment and forward the port
```shell
kubectl expose deployment configmap-two-containers --name=configmap-service --port=8080 --target-port=80

kubectl port-forward service/configmap-service 8080:8080 &

curl http://localhost:8080
```


Change color to red

```shell
kubectl edit configmap color
```


## Update configuration via a ConfigMap in a Pod possessing a sidecar container

Using a `Sidecar Container` to write the HTML file

Prepare
```shell
kubectl create configmap color --from-literal=color=blue
kubectl apply -f ./deployment-with-configmap-and-sidecar-container.yaml
```

Expose
```shell
kubectl expose deployment configmap-sidecar-container --name=configmap-sidecar-service --port=8081 --target-port=80
kubectl port-forward service/configmap-sidecar-service 8081:8081 &
```

## Update configuration via an immutable ConfigMap that is mounted as a volume

An immutable ConfigMap connot be updated after it's created. Any change requires deleting and recreating the ConfigMap.
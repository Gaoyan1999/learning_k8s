# Updating Configuration via a ConfigMap [link](https://kubernetes.io/docs/tutorials/configuration/updating-configuration-via-a-configmap/)


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

create deployment
```
kubectl apply -f ./deployment-with-configmap-as-volume.yaml
```
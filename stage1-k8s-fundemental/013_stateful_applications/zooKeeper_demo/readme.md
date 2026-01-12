# Running ZooKeeper, A Distributed System Coordinator

Setup zookeeper
```shell
kubectl apply -f zookeeper.yaml
```

Inspect them
The servers store each server's identifier in a file called myid in the server's data directory.
```shell
for i in 0 1 2; do kubectl exec zk-$i -- hostname; done
for i in 0 1 2; do echo "myid zk-$i";kubectl exec zk-$i -- cat /var/lib/zookeeper/data/myid; done

# Fully Qualified Domain Name (FQDN)
for i in 0 1 2; do kubectl exec zk-$i -- hostname -f; done

zk-0.zk-hs.default.svc.cluster.local
zk-1.zk-hs.default.svc.cluster.local
zk-2.zk-hs.default.svc.cluster.local
```
The A records in K8S DNS resolve the FQDNS to the Pods' IP addresss.  If Kubernetes reschedules the Pods, it will update the A records with the Pods' new IP addresses, but the A records names will not change.

```shell
kubectl exec zk-0 -- cat /opt/zookeeper/conf/zoo.cfg

clientPort=2181
dataDir=/var/lib/zookeeper/data
dataLogDir=/var/lib/zookeeper/log
tickTime=2000
initLimit=10
syncLimit=2000
maxClientCnxns=60
minSessionTimeout= 4000
maxSessionTimeout= 40000
autopurge.snapRetainCount=3
autopurge.purgeInterval=0
server.1=zk-0.zk-hs.default.svc.cluster.local:2888:3888
server.2=zk-1.zk-hs.default.svc.cluster.local:2888:3888
server.3=zk-2.zk-hs.default.svc.cluster.local:2888:3888
```


## Sanity testing the ensemble

The most basic sanity test is to write data to one ZooKeeper server and to read the data from another.

executes the zkCli.sh to write world to the path /hello on the zk-0 Pod in the ensemble.

```shell
kubectl exec zk-0 -- zkCli.sh create /hello world
```

The `/hello` in `zk-1` will get the data that is created on `zk-0`

```shell
WATCHER::
...
WatchedEvent state:SyncConnected type:None path:null
world
...
```

## Providing durable storage
Delete StatefulSet and then restart it. Notice that even though we recreated all of the Pods, the ensemble still serves the orginal value. 
The 
```shell
kubectl delete statefulset zk

kubectl apply -f zookeeper.yaml
kubectl exec zk-2 -- zkCli.sh get /hello
```

The data is stored in the pvc named `datadir`.

```shell
kubectl get pvc -l app=zk
```

```yaml
volumeMounts:
- name: datadir
  mountPath: /var/lib/zookeeper
```

## Ensuring consistent configuration

```shell
kubectl get sts zk -o yaml
```

```yaml
…
command:
      - sh
      - -c
      - "start-zookeeper \
        --servers=3 \
        --data_dir=/var/lib/zookeeper/data \
        --data_log_dir=/var/lib/zookeeper/data/log \
        --conf_dir=/opt/zookeeper/conf \
        --client_port=2181 \
        --election_port=3888 \
        --server_port=2888 \
        --tick_time=2000 \
        --init_limit=10 \
        --sync_limit=5 \
        --heap=512M \
        --max_client_cnxns=60 \
        --snap_retain_count=3 \
        --purge_interval=12 \
        --max_session_timeout=40000 \
        --min_session_timeout=4000 \
        --log_level=INFO"
…
```

The command used to started the zk servers passed the config as command line parameter.

## Updating the ensemble


Update the number of `cpus`
```shell
kubectl patch sts zk --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/resources/requests/cpu", "value":"0.3"}]'
```

watch the status of the update
```shell
kubectl rollout status sts/zk

waiting for statefulset rolling update to complete 0 pods at revision zk-77cc4ddd5d...
Waiting for 1 pods to be ready...
Waiting for 1 pods to be ready...
Waiting for 1 pods to be ready...
waiting for statefulset rolling update to complete 1 pods at revision zk-77cc4ddd5d...
Waiting for 1 pods to be ready...
Waiting for 1 pods to be ready...
Waiting for 1 pods to be ready...
waiting for statefulset rolling update to complete 2 pods at revision zk-77cc4ddd5d...
Waiting for 1 pods to be ready...
Waiting for 1 pods to be ready...
Waiting for 1 pods to be ready...
statefulset rolling update complete 3 pods at revision zk-77cc4ddd5d...
```

TBD...
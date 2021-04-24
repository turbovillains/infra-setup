k8s.md
===

# Sonobuoy

```
sonobuoy run --wait # 60+ minutes, add --mode quick for short run
results=$(sonobuoy retrieve)
sonobuoy results $results
```

# Connect GitLab
https://docs.gitlab.com/ee/user/project/clusters/add_remove_clusters.html#existing-kubernetes-cluster

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitlab
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: gitlab-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: gitlab
    namespace: kube-system
```

Get Token
```
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep gitlab | awk '{print $1}')
```

Get CA cert
```
kubectl -n kube-system get secret $(kubectl -n kube-system get secret | grep gitlab | awk '{print $1}') -o jsonpath="{['data']['ca\.crt']}" | base64 --decode
```

Add any missing parent CA certs and full CA chain should go to Gitlab config

# Admin user

```
kubectl create serviceaccount k8sadmin -n kube-system
kubectl create clusterrolebinding k8sadmin --clusterrole=cluster-admin --serviceaccount=kube-system:k8sadmin
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | (grep k8sadmin || echo "$_") | awk '{print $1}') | grep token: | awk '{print $2}'
```

# Rough procedure for new k8s cluster

dynamic PV with CSI
metlalb
9 nodes
new template

- create nodes
- create vmware tags for zone and regions
- assign tags to folder
- create storage policy
- install docker
- install k8s master and workers
- install metallb
- make sure resolv.conf on nodes has no wildcard domains in search

```
helm repo update
helm install metallb bitnami/metallb -n metallb-system --create-namespace
```

 
- install nginx ingress
 - make sure to set loadBalancerIP

```
helm repo update
helm install nginx-ingress-controller bitnami/nginx-ingress-controller -n ingress-system --create-namespace
```

Validate it hello is acceible

- install cpi
 - apply manifests
 - create secrets
- taint nodes
```
kubectl taint nodes -l kubernetes.io/os=linux node.cloudprovider.kubernetes.io/uninitialized=true:NoSchedule
```
Topology and failure domain labels should appear in nodes

- install csi
 - apply manifests
 - create secret
 - create storage class

Verify with
```
kubectl get CSIDrivers
kubectl get CSINodes
kubectl get sc
```

Test with ECK

```
helm repo add elastic https://helm.elastic.co
helm repo update
helm install elastic-operator elastic/eck-operator -n elastic-system --create-namespace

cat <<QUICKSTART_ES | kubectl apply -f -
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: quickstart
spec:
  version: 7.12.0
  nodeSets:
  - name: default
    count: 3
    config:
      node.store.allow_mmap: false
QUICKSTART_ES

kubectl get pvc
```


# Hello World

```
kubectl apply -f https://raw.githubusercontent.com/paulbouwer/hello-kubernetes/main/yaml/hello-kubernetes.yaml
```

# kubeadm tokens

```
kubeadm token create --print-join-command
```

# kubeadm config

```
kubectl -n kube-system get cm kubeadm-config -o yaml
```

# CA cert hash
```
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
```

# Multi-master manual CA cert copy from first control plane node

```
USER=oleksii
CONTROL_PLANE_HOSTS="lab03-vm-etc02.node.lab03.noroutine.me lab03-vm-etc03.node.lab03.noroutine.me"
for host in ${CONTROL_PLANE_HOSTS}; do
	ssh ${USER}@${host} sudo mkdir -p /etc/kubernetes/pki /etc/kubernetes/pki/etcd
	rsync -av --rsync-path="sudo rsync" /etc/kubernetes/pki/ca.crt ${USER}@${host}:/etc/kubernetes/pki/ca.crt
	rsync -av --rsync-path="sudo rsync" /etc/kubernetes/pki/ca.key ${USER}@${host}:/etc/kubernetes/pki/ca.key
	rsync -av --rsync-path="sudo rsync" /etc/kubernetes/pki/sa.pub ${USER}@${host}:/etc/kubernetes/pki/sa.pub
	rsync -av --rsync-path="sudo rsync" /etc/kubernetes/pki/sa.key ${USER}@${host}:/etc/kubernetes/pki/sa.key
	rsync -av --rsync-path="sudo rsync" /etc/kubernetes/pki/front-proxy-ca.crt ${USER}@${host}:/etc/kubernetes/pki/front-proxy-ca.crt
	rsync -av --rsync-path="sudo rsync" /etc/kubernetes/pki/front-proxy-ca.key ${USER}@${host}:/etc/kubernetes/pki/front-proxy-ca.key
	rsync -av --rsync-path="sudo rsync" /etc/kubernetes/pki/etcd/ca.crt ${USER}@${host}:/etc/kubernetes/pki/etcd/ca.crt
	rsync -av --rsync-path="sudo rsync" /etc/kubernetes/pki/etcd/ca.key ${USER}@${host}:/etc/kubernetes/pki/etcd/ca.key
done
```

```
USER=oleksii
CONTROL_PLANE_HOSTS="lab03-vm-etc02.node.lab03.noroutine.me lab03-vm-etc03.node.lab03.noroutine.me"
for host in ${CONTROL_PLANE_HOSTS}; do
	rsync -av --rsync-path="sudo rsync" /var/lib/kubelet/kubeadm-flags.env ${USER}@${host}:/var/lib/kubelet/kubeadm-flags.env
done
```

```
kubeadm join 10.0.23.20:6443 --token b0f7b8.8d1767876297d85c --discovery-token-ca-cert-hash sha256:84180784509cbfc7db40cac6fd6f938c0e3ca63a34beefd8147f331a0daca5a0 --control-plane
```

# Working on masters

```
To start administering your cluster from this node, you need to run the following as a regular user:

	mkdir -p $HOME/.kube
	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	sudo chown $(id -u):$(id -g) $HOME/.kube/config

Run 'kubectl get nodes' to see this node join the cluster.
```

# Dynamic PV

### CPI
!! [Manifests](https://github.com/kubernetes/cloud-provider-vsphere/blob/master/releases/)

!! [zones and regions](https://medium.com/@abhishek.amjeet/building-availability-zones-on-vmware-with-kubernetes-8a60aae63a)

`insecureFlag: true` *check how to trust our CA*
### CSI

https://vsphere-csi-driver.sigs.k8s.io/driver-deployment/installation.html

Important is the name of the file, should be csi-vsphere.conf!!!
Important to change cluster-id in the file!!!
```
kubectl create secret generic vsphere-config-secret --from-file=csi-vsphere.conf=$HOME/noroutine/infra/secrets/csi-vsphere.conf --namespace=kube-system
```

```

https://github.com/kubernetes-sigs/vsphere-csi-driver/tree/master/manifests

kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/master/manifests/v2.1.1/vsphere-7.0u1/vanilla/rbac/vsphere-csi-controller-rbac.yaml

kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/master/manifests/v2.1.1/vsphere-7.0u1/vanilla/deploy/vsphere-csi-controller-deployment.yaml

kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/master/manifests/v2.1.1/vsphere-7.0u1/vanilla/deploy/vsphere-csi-node-ds.yaml

```
### Create Storage Policy 

https://cloud-provider-vsphere.sigs.k8s.io/tutorials/kubernetes-on-vsphere-with-kubeadm.html

lab04-PV-Space-Efficient

### Extra masters should have the same 
```
KUBELET_KUBEADM_ARGS="--cloud-provider=external --network-plugin=cni --pod-infra-container-image=k8s.gcr.io/pause:3.2"
```
inside `/var/lib/kubelet/kubeadm-flags.env` 
### Other links
https://cloud-provider-vsphere.sigs.k8s.io/tutorials/kubernetes-on-vsphere-with-kubeadm.html

https://tsmith.co/2021/kubernetes-homelab-new-cluster-with-vsphere-csi/

https://github.com/kubernetes/cloud-provider-vsphere/blob/master/docs/book/tutorials/kubernetes-on-vsphere-with-kubeadm.md

Alternatives

https://jonathangazeley.com/2021/01/05/using-truenas-to-provide-persistent-storage-for-kubernetes/

https://github.com/kubernetes-sigs/nfs-ganesha-server-and-external-provisioner

https://github.com/helm/charts/tree/master/stable/nfs-client-provisioner

https://github.com/longhorn/longhorn

https://openebs.io/

https://github.com/kubernetes-sigs/vsphere-csi-driver
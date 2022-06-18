# Hands-on Kubernetes-X : Kubernetes Users and RBAC

The purpose of this hands-on training is to give students the knowledge of authentication and authorization in kubernetes.

## Learning Outcomes

At the end of this hands-on training, students will be able to;

- describe authentication and authentication mechanism in Kubernetes.

- create users in Kubernetes.

- use role and rolebinding objects in Kubernetes.

## Outline

- Part 1 - Setting up the Kubernetes Cluster

- Part 2 - Creating Users in Kubernetes Cluster

- Part 3 - Using RBAC Authorization

## Part 1 - Setting up the Kubernetes Cluster

- Launch a Kubernetes Cluster of Ubuntu 20.04 with two nodes (one master, one worker) using the [Cloudformation Template to Create Kubernetes Cluster](./cfn-template-to-create-k8s-cluster.yml). *Note: Once the master node is up and running, the worker node automatically joins the cluster.*

>*Note: If you have a problem with the Kubernetes cluster, you can use this link for the lesson.*
>https://www.katacoda.com/courses/kubernetes/playground

- Check if Kubernetes is running and nodes are ready.

```bash
kubectl cluster-info
kubectl get no
```

## Part 2 - Creating Users in Kubernetes Cluster

- Create a user on the master machine.

```bash
sudo useradd -m john
```

- Switch user as John.

```bash
sudo su - john
```

- Create a private key.

```bash
openssl genrsa -out john.key 2048
```

- Create a certificate signing request (CSR). `CN is the username.`

```bash
openssl req -new -key john.key \
  -out john.csr \
  -subj "/CN=john" 
```

- Sign the CSR with the Kubernetes CA. We have to use the CA cert and key which are normally in /etc/kubernetes/pki/.
We can do this with root privilege.

```bash
exit
whoami
#ubuntu
sudo openssl x509 -req -in /home/john/john.csr \
  -CA /etc/kubernetes/pki/ca.crt \
  -CAkey /etc/kubernetes/pki/ca.key \
  -CAcreateserial \
  -out /home/john/john.crt -days 500
```

- Switch user as John again.

```bash
sudo su - john
```

- Create a “.certs” directory where we are going to store the user public and private key.

```bash
pwd
#/home/john
mkdir .certs && mv john.crt john.key .certs
```

- Create the user inside Kubernetes. For this, we create kubeconfig file. There are three parts in the kubeconfig file. 
  - cluster
  - user
  - context

- Configure the user part.

```bash
kubectl config set-credentials john \
  --client-certificate=/home/john/.certs/john.crt \
  --client-key=/home/john/.certs/john.key
```

- Check the kubeconfig file.

```bash
cat .kube/config
```

- Create a context for the user.

```bash
kubectl config set-context john-context \
  --cluster=kubernetes --user=john
```

- Check the kubeconfig file again and notice the differences.

```bash
cat .kube/config
```

- Configure the cluster part. Copy the `cluster part` of `/home/ubuntu/.kube/config` which is like below.

```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMvakNDQWVhZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJeU1EWXdOakEyTlRJd05Wb1hEVE15TURZd016QTJOVEl3TlZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTE1ICitJcVA1bmc5Vmk4Y1VCTEp6NHBaMm5hd1hVMEdBUmNLbjllL093Q3pFMzl6aXFwRWYyZmh0a2EydGtRakdmY0EKUHB6alg4bWpjWkc3YTJodFhyb3BNSnRqUUhoYktLR1dlci9ZWWxGeHBJQjU2VG1aNTZsQWZCMllvQUh3a1RoRwpVM0pJcm8vQ3E5d3N6RzdNVjRIMDZhSEZ1aDNkcFBweDQ3WUxNaE1JdTNNVFhpZ09oUkk3ai9rZ1pRd1REbWdPCkFDV1dyRzRsYTQyYVN3UHVCOXpsRzk0RGt4ck9mQ0UxU0dFbW9EUVcyNFh2UTQ2RGNHRy9GZkJFVlBIZ0tUSVYKZVZmTTRuMEJvN3FaMFZLZFNPK1FxZm9NeHd3YXlLT012ZzI4NVkybVJRbHNoVXYwRUdUQ0hZMk5obER2Vk1mYQp4MzNPWVVtcnZlVnphKzJIZno4Q0F3RUFBYU5aTUZjd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZKV042ZC9sbVUzVndsSGpuaVhYVjF4bElWYllNQlVHQTFVZEVRUU8KTUF5Q0NtdDFZbVZ5Ym1WMFpYTXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBQ0ZDaWVqVldzUkR3TnRvdENsdgo2YzJtQWhpYmwvc2haeEhyVnJ6UDN3MTV2SmZhcWU5KzgvR1dRWGVrT3U1NzdQSU1rZFFsdjMwNk5HOFNwVUU3Ck01NTRxUE9ZMHVDL01qQWNXM0dSaXFDYVROOGJ6SzA1VVU3Qm11UGo1NDM2QnZ1YWxSdTk4ZGJiZVBGNXAyZ3AKNS9za0JQRVF6QlA3S3I0VG9lYXpIV3RuaFlNTUxjN0RsQjFBYk9ZWSs4S2VwVjNwcFR6MGt0UkhTSmlWKzRwawpFd25vOFJIbjBmVWE4VCtmcGpCNzR1SFU4SHV4UnBpaHFYZ0k5dlMxYlRBTkNSL0ZjYVJnaGdxYlY2TmV2Tzk3CmJlUGZSOWFCMitIdlF1ZnM4OGJoSy9qU1BSQjFsNHUwS2pOMGROeThXN0s3UC9uaHd3UUZxNU9taXJnQ2l1SUIKbFRnPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    server: https://172.31.91.188:6443
  name: kubernetes
contexts:
...
users:
...
```

- And paste it to the `cluster part` of `/home/john/.kube/config` which is like below.

```yaml
apiVersion: v1
clusters: null # Paste the cluster inormation instead of this line.
contexts:
- context:
    cluster: kubernetes
    user: john
  name: john-context
current-context: ""
kind: Config
preferences: {}
users:
- name: john
  user:
    client-certificate: /home/john/.certs/john.crt
    client-key: /home/john/.certs/john.key
```

- We will get a file like the below.

```bash
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMvakNDQWVhZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJeU1EWXdOakEyTlRJd05Wb1hEVE15TURZd016QTJOVEl3TlZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTE1ICitJcVA1bmc5Vmk4Y1VCTEp6NHBaMm5hd1hVMEdBUmNLbjllL093Q3pFMzl6aXFwRWYyZmh0a2EydGtRakdmY0EKUHB6alg4bWpjWkc3YTJodFhyb3BNSnRqUUhoYktLR1dlci9ZWWxGeHBJQjU2VG1aNTZsQWZCMllvQUh3a1RoRwpVM0pJcm8vQ3E5d3N6RzdNVjRIMDZhSEZ1aDNkcFBweDQ3WUxNaE1JdTNNVFhpZ09oUkk3ai9rZ1pRd1REbWdPCkFDV1dyRzRsYTQyYVN3UHVCOXpsRzk0RGt4ck9mQ0UxU0dFbW9EUVcyNFh2UTQ2RGNHRy9GZkJFVlBIZ0tUSVYKZVZmTTRuMEJvN3FaMFZLZFNPK1FxZm9NeHd3YXlLT012ZzI4NVkybVJRbHNoVXYwRUdUQ0hZMk5obER2Vk1mYQp4MzNPWVVtcnZlVnphKzJIZno4Q0F3RUFBYU5aTUZjd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZKV042ZC9sbVUzVndsSGpuaVhYVjF4bElWYllNQlVHQTFVZEVRUU8KTUF5Q0NtdDFZbVZ5Ym1WMFpYTXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBQ0ZDaWVqVldzUkR3TnRvdENsdgo2YzJtQWhpYmwvc2haeEhyVnJ6UDN3MTV2SmZhcWU5KzgvR1dRWGVrT3U1NzdQSU1rZFFsdjMwNk5HOFNwVUU3Ck01NTRxUE9ZMHVDL01qQWNXM0dSaXFDYVROOGJ6SzA1VVU3Qm11UGo1NDM2QnZ1YWxSdTk4ZGJiZVBGNXAyZ3AKNS9za0JQRVF6QlA3S3I0VG9lYXpIV3RuaFlNTUxjN0RsQjFBYk9ZWSs4S2VwVjNwcFR6MGt0UkhTSmlWKzRwawpFd25vOFJIbjBmVWE4VCtmcGpCNzR1SFU4SHV4UnBpaHFYZ0k5dlMxYlRBTkNSL0ZjYVJnaGdxYlY2TmV2Tzk3CmJlUGZSOWFCMitIdlF1ZnM4OGJoSy9qU1BSQjFsNHUwS2pOMGROeThXN0s3UC9uaHd3UUZxNU9taXJnQ2l1SUIKbFRnPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    server: https://172.31.91.188:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: john
  name: john-context
current-context: ""
kind: Config
preferences: {}
users:
- name: john
  user:
    client-certificate: /home/john/.certs/john.crt
    client-key: /home/john/.certs/john.key
```

- Notice that `current-context` is empty. Change the `current-context` line as below,

```yaml
current-context: john-context
```

## Part 3 - Using RBAC Authorization

- Now we have a user “john” created. As we have not defined any authorization for john, he should get forbidden access to all cluster resources.

```bash
kubectl get no
#Error from server (Forbidden): nodes is forbidden: User "john" cannot list resource "nodes" in API group "" at the cluster scope
kubectl get po
#Error from server (Forbidden): pods is forbidden: User "john" cannot list resource "pods" in API group "" in the namespace "default"
```

### role and rolebinding

- We will create a Role. A Role always sets permissions within a particular namespace; when you create a Role, you have to specify the namespace it belongs in. For this, switch the user to ubuntu.

```bash
exit
whoami
#ubuntu
```

- Create a file and name it `role.yaml`.

```bash
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

- Create the role.

```bash
kubectl apply -f role.yaml
```

- A role binding grants the permissions defined in a role to a user or set of users. It holds a list of subjects (users, groups, or service accounts), and a reference to the role being granted. A RoleBinding grants permissions within a specific namespace. Create a file and name it `rolebinding.yaml`.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
# This role binding allows "john" to read pods in the "default" namespace.
# You need to already have a Role named "pod-reader" in that namespace.
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
# You can specify more than one "subject"
- kind: User
  name: john # "name" is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  # "roleRef" specifies the binding to a Role / ClusterRole
  kind: Role #this must be Role or ClusterRole
  name: pod-reader # this must match the name of the Role or ClusterRole you wish to bind to
  apiGroup: rbac.authorization.k8s.io
```

- Create the rolebinding object.

```bash
kubectl apply -f rolebinding.yaml
```

- List the role and rolebinding.

```bash
kubectl get role
kubectl get rolebinding
```

- Create a pod.

```bash
kubectl run mypod --image=nginx
kubectl get po
```

- Switch user as John again.

```bash
sudo su - john
```

- List the pods.

```bash
kubectl get po
```

- Try to execute the following commands.

```bash
kubectl get deploy
#Error from server (Forbidden): deployments.apps is forbidden: User "john" cannot list resource "deployments" in API group "apps" in the namespace "default"
kubectl get po -n kube-system
#Error from server (Forbidden): pods is forbidden: User "john" cannot list resource "pods" in API group "" in the namespace "kube-system"
kubectl get ns
#Error from server (Forbidden): namespaces is forbidden: User "john" cannot list resource "namespaces" in API group "" at the cluster scope
kubectl get no
Error from server (Forbidden): nodes is forbidden: User "john" cannot list resource "nodes" in API group "" at the cluster scope
```

- Since we haven't given John any privileges except pods in `default` namespace, he should forbid access to all other resources.

### clusterrole and clusterrolebinding

- A Role always sets permissions within a particular namespace; ClusterRole, by contrast, is a non-namespaced resource. The resources have different names (Role and ClusterRole) because a Kubernetes object always has to be either namespaced or not namespaced; it can't be both.

- ClusterRoles have several uses. You can use a ClusterRole to:

  - define permissions on namespaced resources and be granted within individual namespace(s)
  - define permissions on namespaced resources and be granted across all namespaces
  - define permissions on cluster-scoped resources

- If you want to define a role within a namespace, use a Role; if you want to define a role cluster-wide, use a ClusterRole.

- A ClusterRole can be used to grant the same permissions as a Role. Because ClusterRoles are cluster-scoped, you can also use them to grant access to:

  - cluster-scoped resources (like nodes)

  - non-resource endpoints (like /healthz)

  - namespaced resources (like Pods), across all namespaces

For example, you can use a ClusterRole to allow a particular user to run `kubectl get pods --all-namespaces`.

- Create a clusterrole.yaml file as below. For this, switch user to ubuntu.

```bash
exit
whoami
#ubuntu
```

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  # "namespace" omitted since ClusterRoles are not namespaced
  name: secret-reader
rules:
- apiGroups: [""]
  #
  # at the HTTP level, the name of the resource for accessing Secret
  # objects is "secrets"
  resources: ["secrets"]
  verbs: ["get", "watch", "list"]
```

- Create the clusterrole.

```bash
kubectl apply -f clusterrole.yaml
```

- To grant permissions across a whole cluster, you can use a ClusterRoleBinding. The following ClusterRoleBinding allows a user to read secrets in any namespace. Create a clusterrolebinding.yaml file as below.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
# This cluster role binding allows anyone in the "manager" group to read secrets in any namespace.
kind: ClusterRoleBinding
metadata:
  name: read-secrets-global
subjects:
- kind: User
  name: john # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

- Create the clusterrolebinding.

```bash
kubectl apply -f clusterrolebinding.yaml
```

- List the clusterrole and clusterrolebinding.

```bash
kubectl get clusterrole
kubectl get clusterrolebinding
```

- Switch user as John.

```bash
sudo su - john
```

- List the secrets.

```bash
kubectl get secret
kubectl get secret --all-namespaces
```

- - Try to execute the following commands.

```bash
kubectl get deploy
#Error from server (Forbidden): deployments.apps is forbidden: User "john" cannot list resource "deployments" in API group "apps" in the namespace "default"
kubectl get po -n kube-system
#Error from server (Forbidden): pods is forbidden: User "john" cannot list resource "pods" in API group "" in the namespace "kube-system"
kubectl get ns
#Error from server (Forbidden): namespaces is forbidden: User "john" cannot list resource "namespaces" in API group "" at the cluster scope
kubectl get no
Error from server (Forbidden): nodes is forbidden: User "john" cannot list resource "nodes" in API group "" at the cluster scope
```

- Since we haven't given John any privileges except secrets, he should forbid access to all other resources.
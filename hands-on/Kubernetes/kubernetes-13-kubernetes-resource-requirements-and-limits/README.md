# Hands-on Kubernetes-XX : Managing Resources for Containers

Purpose of this hands-on training is to give students the knowledge of managing resources for containers.

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- managing resources for containers in Kubernetes.

## Outline

- Part 1 - Setting up the Kubernetes Cluster

- Part 2 - Managing Resources for Containers

- Part 3 - Requests

- Part 4 - limits

- Part 5 - Configure Default Memory and CPU Requests and Limits for a Namespace

- Part 6 - Configure Memory and CPU Quotas for a Namespace

- Part 7 - Configure Quotas for API Objects

## Part 1 - Setting up the Kubernetes Cluster

- Launch a Kubernetes Cluster of Ubuntu 20.04 with two nodes (one master, one worker) using the [Cloudformation Template to Create Kubernetes Cluster](./cfn-template-to-create-k8s-cluster.yml). *Note: Once the master node up and running, worker node automatically joins the cluster.*

>*Note: If you have problem with kubernetes cluster, you can use this link for lesson.*
>https://www.katacoda.com/courses/kubernetes/playground

- Check if Kubernetes is running and nodes are ready.

```bash
kubectl cluster-info
kubectl get no
```

## Part 2 - Managing Resources for Containers

- When we specify a Pod, we can optionally specify how much of each resource a Container needs. The most common resources to specify are CPU and memory (RAM); there are others.

- When we specify the resource request for Containers in a Pod, the scheduler uses this information to decide which node to place the Pod on. 

- When we specify a resource limit for a Container, the kubelet enforces those limits so that the running container is not allowed to use more of that resource than the limit we set. The kubelet also reserves at least the request amount of that system resource specifically for that container to use.

## Part 3 - Requests

- If the node where a Pod is running has enough of a resource available, it's possible (and allowed) for a container to use more resource than its request for that resource specifies. However, a container is not allowed to use more than its `resource limit`.

- For example, if we set a `memory request` of 256 MiB for a container, and that container is in a Pod scheduled to a Node with 8GiB of memory and no other Pods, then the container can try to use more RAM.

- If we set a `memory limit` of 4GiB for that Container, the kubelet (and container runtime) enforce the limit. The runtime `prevents` the container from using more than the configured `resource limit`. 

- For example: when a process in the container tries to consume more than the allowed amount of memory, the system kernel terminates the process that attempted the allocation, with an out of memory (OOM) error.

> **Note:** If a Container specifies its own memory limit, but does not specify a memory request, Kubernetes automatically assigns a memory request that matches the limit. Similarly, if a Container specifies its own CPU limit, but does not specify a CPU request, Kubernetes automatically assigns a CPU request that matches the limit.

- Let's see this. - Create yaml file named `clarus-deploy.yaml`. Notice that, there is 30 replicas.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    environment: dev
spec:
  replicas: 30
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```

- Create the deployment with `kubectl apply` command.

```bash
kubectl apply -f clarus-deploy.yaml
```

- List the pods and notice that all pods are running. Because, we do not specify any resources.

```bash
kubectl get po -o wide
```

- Delete the deployment.

```bash
kubectl delete -f clarus-deploy.yaml 
```

- This time, we will update our deployment as below.vWe add resources section. In our case, we have one worker node that is aws t3 medium. It has 2 vCPUs and 4  GiB memory. At this time, just focus on memory field. We specify 500 Mi for memory request.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    environment: dev
spec:
  replicas: 20
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "500Mi"
            cpu: "100m"
          limits:
            memory: "750Mi"
            cpu: "750m"
```

- Let's create the deployment.

```bash
kubectl apply -f clarus-deploy.yaml
```

- List the pods and notice that just 7 pods are running. Because of the memory resource requests.

```bash
kubectl get po -o wide
```

- Delete the deployment.

```bash
kubectl delete -f clarus-deploy.yaml 
```

- Update the clarus-deploy yaml and make resources.requests.memory 300Mi. Execute the deployment again. 

```bash
kubectl apply -f clarus-deploy.yaml
```

- List the pods and notice that, this time 12 pods are running.

```bash
kubectl get po -o wide
```

- Inspect a pod whose status is pending and note that it gives insufficient memory warning. 

```bash
kubectl describe <pod-name> 
```

- Delete the deployment.

```bash
kubectl delete -f clarus-deploy.yaml 
```

- We understand memory resources. This time, let's see CPU resources. 

- Limits and requests for CPU resources are measured in cpu units. One cpu, in Kubernetes, is equivalent to `1 vCPU/Core` for cloud providers and 1 hyperthread on bare-metal Intel processors. 

- In our case, t3 medium instance has 2 vCPU's. Update the clarus-deploy.yaml as below. We make resources.requests.cpu 500 m.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    environment: dev
spec:
  replicas: 20
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "100Mi"
            cpu: "500m"
          limits:
            memory: "750Mi"
            cpu: "750m"
```

- Execute the deployment.

```bash
kubectl apply -f clarus-deploy.yaml
```

- List the pods and notice that just 3 pods are running.

```bash
kubectl get po -o wide
```

- Inspect a pod whose status is pending and note that this time it gives insufficient cpu warning.

```bash
kubectl describe <pod-name> 
```

- Delete the deployment.

```bash
kubectl delete -f clarus-deploy.yaml 
```

## Part 4 - limits

- We have seen that requests are used for during scheduling. But, limits are used during execution. For example, when a process in the container tries to consume more than the specified limit of memory, the system kernel terminates the process that attempted the allocation, with an out of memory (OOM) error. 

- Firstly, we will see how `memory limit` works. For this, it is required to install metric-server.

### Install Metric Server 

- First Delete the existing Metric Server if any.

```bash
kubectl delete -n kube-system deployments.apps metrics-server
```

- Get the Metric Server form [GitHub](https://github.com/kubernetes-sigs/metrics-server/releases/tag/v0.4.3).

```bash
wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.3/components.yaml
```


- Edit the file `components.yaml`. Add the following arguments to the `Deployment` part in the file.

```yaml
          - --kubelet-insecure-tls
          - --kubelet-preferred-address-types=InternalIP,Hostname,InternalDNS,ExternalDNS,ExternalIP
```

- We will get a result like below.

```yaml
apiVersion: apps/v1
kind: Deployment
......
      containers:
      - name: metrics-server
        image: k8s.gcr.io/metrics-server/metrics-server:v0.3.7
        imagePullPolicy: IfNotPresent
      - args:
        - --cert-dir=/tmp
        - --secure-port=4443
        - --kubelet-insecure-tls 
        - --kubelet-preferred-address-types=InternalIP,Hostname,InternalDNS,ExternalDNS,ExternalIP
        - --kubelet-use-node-status-port
        ports:
        - name: main-port
          containerPort: 4443 
......	
```

- Add `metrics-server` to your Kubernetes instance.

```bash
$ kubectl apply -f components.yaml
```

- Verify the existace of `metrics-server` run by below command

```bash
kubectl -n kube-system get pods
```

Verify `metrics-server` can access resources of the pods and nodes.

```bash
kubectl top pods
kubectl top nodes
```

### memory limit of a container 

- Create a file and name it memory-limit.yaml.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: memory-limit
spec:
  containers:
  - name: memory-limit
    image: polinux/stress
    resources:
      limits:
        memory: "200Mi"
      requests:
        memory: "100Mi"
    command: ["stress"]
    args: ["--vm", "1", "--vm-bytes", "150M", "--vm-hang", "1"]
```

- The args section in the configuration file provides arguments for the Container when it starts. The "--vm-bytes", "150M" arguments tell the Container to attempt to allocate 150 MiB of memory.

- Create the Pod.

```bash
kubectl apply -f memory-limit.yaml
```

- Verify that the Pod Container is running:

```bash
kubectl get pod
```

- View detailed information about the Pod:

```
kubectl get pod memory-limit --output=yaml
```

The output shows that the one Container in the Pod has a memory request of 100 MiB and a memory limit of 200 MiB.

...
resources:
  limits:
    memory: 200Mi
  requests:
    memory: 100Mi
...

- Run kubectl top to fetch the metrics for the pod:

```bash
kubectl top  pod memory-limit 
```

- The output shows that the Pod is using about 150 MiB. This is greater than the Pod's 100 MiB request, but within the Pod's 200 MiB limit.

```bash
NAME           CPU(cores)   MEMORY(bytes)   
memory-limit   54m          150Mi 
```

Delete your Pod:

```bash
kubectl delete -f memory-limit.yaml 
```

### Exceed a Container's memory limit

- A Container can exceed its memory request if the Node has memory available. But a Container is not allowed to use more than its memory limit. If a Container allocates more memory than its limit, the Container becomes a candidate for termination. If the Container continues to consume memory beyond its limit, the Container is terminated. If a terminated Container can be restarted, the kubelet restarts it, as with any other type of runtime failure.

- In this exercise, we create a Pod that attempts to allocate more memory than its limit. Update the memory-limit.yaml like below. We configure file for a Pod that has one Container with a memory request of 50 MiB and a memory limit of 100 MiB.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: memory-limit
spec:
  containers:
  - name: memory-limit
    image: polinux/stress
    resources:
      limits:
        memory: "100Mi"
      requests:
        memory: "50Mi"
    command: ["stress"]
    args: ["--vm", "1", "--vm-bytes", "250M", "--vm-hang", "1"]
```

- In the args section of the configuration file, we can see that the Container will attempt to allocate 250 MiB of memory, which is well above the 100 MiB limit.

```bash
kubectl apply -f memory-limit.yaml
```

- View detailed information about the Pod.

```bash
kubectl get pod memory-limit
```

- At this point, the Container might be running or killed. Repeat the preceding command until the Container is killed.

```bash
NAME           READY   STATUS      RESTARTS   AGE
memory-limit   0/1     OOMKilled   2          29s
```

- Get a more detailed view of the Container status:

```bash
kubectl get pod memory-limit --output=yaml
```

- The output shows that the Container was killed because it is out of memory (OOM).

```yaml
    lastState:
      terminated:
        containerID: docker://a34804a2fb007eff9b40b479cb3a4abad8d03f314e4550a23519447d050491f1
        exitCode: 1
        finishedAt: "2021-04-27T08:17:58Z"
        reason: OOMKilled
        startedAt: "2021-04-27T08:17:58Z"
```

- The Container in this hands-on can be restarted, so the kubelet restarts it. Repeat this command several times to see that the Container is repeatedly killed and restarted:

```bash
kubectl get pod memory-limit
```

The output shows that the Container is killed, restarted, killed again, restarted again, and so on:

```bash
NAME           READY   STATUS             RESTARTS   AGE
memory-limit   0/1     CrashLoopBackOff   5          5m34s
```

- View detailed information about the Pod history.

```bash
kubectl describe pod memory-limit
```

The output shows that the Container starts and fails repeatedly.

```
  Normal   Created    7m11s (x4 over 7m53s)   kubelet            Created container memory-limit
  Normal   Started    7m11s (x4 over 7m52s)   kubelet            Started container memory-limit
  Normal   Pulled     7m11s                   kubelet            Successfully pulled image "polinux/stress" in 229.210862ms
  Warning  BackOff    2m47s (x27 over 7m51s)  kubelet            Back-off restarting failed containerer
```

- Delete your Pod.

```bash
kubectl delete -f memory-limit.yaml
```

### CPU limit of a container 

In this part, we create a Pod that has one container. The container has a request of 0.5 CPU and a limit of 1 CPU. Here is the configuration file for the Pod. Create a yaml file and name it cpu-limit.yaml.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: cpu-limit
spec:
  containers:
  - name: cpu-limit
    image: vish/stress
    resources:
      limits:
        cpu: "1"
      requests:
        cpu: "0.5"
    args:
    - -cpus
    - "2"
```

- The args section of the configuration file provides arguments for the container when it starts. The -cpus "2" argument tells the Container to attempt to use 2 CPUs.

Create the Pod.

```bash
kubectl apply -f cpu-limit.yaml
```

- Verify that the Pod is running.

```bash
kubectl get pod cpu-limit
```

- View detailed information about the Pod.

```bash
kubectl get pod cpu-limit --output=yaml
```

- The output shows that the one container in the Pod has a CPU request of 500 milliCPU and a CPU limit of 1 CPU.

```yaml
resources:
  limits:
    cpu: "1"
  requests:
    cpu: 500m
```

- Use kubectl top to fetch the metrics for the pod.

```bash
kubectl top pod cpu-limit
```

- This output shows that the Pod is using 999 milliCPU, which is slightly less than the limit of 1 CPU specified in the Pod configuration.

```bash
NAME        CPU(cores)   MEMORY(bytes)   
cpu-limit   999m         1Mi
```

- Recall that by setting -cpu "2", you configured the Container to attempt to use 2 CPUs, but the Container is only being allowed to use about 1 CPU. The container's CPU use is being throttled, because the container is attempting to use more CPU resources than its limit.

- Delete the pod.

```bash
kubectl delete -f cpu-limit.yaml
```

> Pay attention to that, If a container try to exceed its memory limit, the system terminate the container. But if a container try to exceed its CPU limit, the system does not terminate container, but throttle its CPU usage.

## Part 5 - Configure Default Memory and CPU Requests and Limits for a Namespace

### If we do not specify a CPU limit for a Container, then one of these situations applies:

- The Container has no upper bound on the CPU resources it can use. The Container could use all of the CPU resources available on the Node where it is running.

- The Container is running in a namespace that has a default CPU limit, and the Container is automatically assigned the default limit. Cluster administrators can use a LimitRange to specify a default value for the CPU limit.

### If we do not specify a memory limit for a Container, one of the following situations applies:

- The Container has no upper bound on the amount of memory it uses. The Container could use all of the memory available on the Node where it is running which in turn could invoke the OOM Killer. Further, in case of an OOM Kill, a container with no resource limits will have a greater chance of being killed.

- The Container is running in a namespace that has a default memory limit, and the Container is automatically assigned the default limit. Cluster administrators can use a LimitRange to specify a default value for the memory limit.

### LimitRange object:

- In kubernetes, we can assign deault memory and CPU requests and limits for Namespaces with the `LimitRange` object.

- Create a namespace named `resources-limits`.

```bash
kubectl create ns resources-limits
```

- List the namespaces.

```bash
kubectl get ns
```

### Default cpu-limit

Now, we will create a LimitRange object. Create a file and name it cpu-limitrange.yaml.

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: cpu-limit-range
spec:
  limits:
  - default:
      cpu: 1
    defaultRequest:
      cpu: 0.5
    type: Container
```

- Create the LimitRange in the resources-limits namespace:

```
kubectl apply -f cpu-limitrange.yaml --namespace=resources-limits
```

- Now if a Container is created in the default-cpu-example namespace, and the Container does not specify its own values for CPU request and CPU limit, the Container is given a default CPU request of 0.5 and a default CPU limit of 1. 

- Let's see this. Create a file and name it clarus-pod.yaml.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: default-cpu
  namespace: resources-limits
spec:
  containers:
  - name: default-cpu
    image: nginx
```

- Create the pod.

```bash
kubectl apply -f clarus-pod.yaml
```

- View the Pod's specification:

```bash
kubectl get pod default-cpu --output=yaml --namespace=resources-limits
```

- The output shows that the Pod's Container has a CPU request of 500 millicpus and a CPU limit of 1 cpu. These are the default values specified by the LimitRange.

```yaml
containers:
- image: nginx
  imagePullPolicy: Always
  name: default-cpu
  resources:
    limits:
      cpu: "1"
    requests:
      cpu: 500m
```

- Delete the pod.

```bash
kubectl delete -f clarus-pod.yaml
```

### What if we specify a Container's limit, but not its request?

- Update the clarus-pod.yaml. This time we will add `resources.limits`, but not `resources.requests`. 

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: default-cpu
  namespace: resources-limits
spec:
  containers:
  - name: default-cpu
    image: nginx
    resources:
      limits:
        cpu: "1500"
```

- Create the Pod.

```bash
kubectl apply -f clarus-pod.yaml
```

- View the Pod specification:

```bash
kubectl get pod default-cpu --output=yaml --namespace=resources-limits
```

- The output shows that the Container's CPU request is set to match its CPU limit. Notice that the Container was not assigned the default CPU request value of 0.5 cpu.

```yaml
containers:
- image: nginx
  imagePullPolicy: Always
  name: default-cpu
  resources:
    limits:
      cpu: 1500m
    requests:
      cpu: 1500m
```

- Delete the pod.

```bash
kubectl delete -f clarus-pod.yaml
```

### What if we specify a Container's request, but not its limit?

- Update the clarus-pod.yaml. This time we will add `resources.requests` , but not `resources.limits`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: default-cpu
  namespace: resources-limits
spec:
  containers:
  - image: nginx
    imagePullPolicy: Always
    name: default-cpu
    resources:
      requests:
        cpu: "0.7"
```

- Create the Pod.

```bash
kubectl apply -f clarus-pod.yaml
```

- View the Pod specification:

```bash
kubectl get pod default-cpu --output=yaml --namespace=resources-limits
```

- The output shows that the Container's CPU request is set to the value specified in the Container's configuration file. The Container's CPU limit is set to 1 cpu, which is the default CPU limit for the namespace.

```yaml
containers:
- image: nginx
  imagePullPolicy: Always
  name: default-cpu
  resources:
    limits:
      cpu: "1"
    requests:
      cpu: 700m
```

- Delete the pod.

```bash
kubectl delete -f clarus-pod.yaml
```

### Default memory-limit

- This time, we will create a LimitRange object for memory. Create a file and name it memory-limitrange.yaml

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: mem-limit-range
spec:
  limits:
  - default:
      memory: 512Mi
    defaultRequest:
      memory: 256Mi
    type: Container
```

- Create the LimitRange in the resources-limits namespace:

```
kubectl apply -f memory-limitrange.yaml --namespace=resources-limits
```

- Now if a Container is created in the resources-limits namespace, and the Container does not specify its own values for memory request and memory limit, the Container is given a default memory request of 256 MiB and a default memory limit of 512 MiB.

- Let's update the clarus-pod.yaml like below. The Container does not specify a memory request and limit. 

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: default-memory
  namespace: resources-limits
spec:
  containers:
  - name: default-memory
    image: nginx
```

- Create the Pod.

```bash
kubectl apply -f clarus-pod.yaml
```

- View detailed information about the Pod.

```
kubectl get pod default-memory --output=yaml --namespace=resources-limits
```

- The output shows that the Pod's Container has a memory request of 256 MiB and a memory limit of 512 MiB. These are the default values specified by the LimitRange.

```yaml
containers:
- image: nginx
  imagePullPolicy: Always
  name: default-memory
  resources:
    limits:
      cpu: "1"
      memory: 512Mi
    requests:
      cpu: 500m
      memory: 256Mi
```

- Delete your Pod.

```bash
kubectl delete -f clarus-pod.yaml
```

### What if we specify a Container's limit, but not its request?

- Update the clarus-pod.yaml. The Container specifies a memory limit, but not a request.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: default-memory
  namespace: resources-limits
spec:
  containers:
  - name: default-memory
    image: nginx
    resources:
      limits:
        memory: "1Gi"
```

Create the Pod.

```bash
kubectl apply -f clarus-pod.yaml
```

- View detailed information about the Pod.

```bash
kubectl get pod default-memory --output=yaml --namespace=resources-limits
```

- The output shows that the Container's memory request is set to match its memory limit. Notice that the Container was not assigned the default memory request value of 256Mi.

```yaml
resources:
  limits:
    cpu: "1"
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 1Gi
```

- Delete the pod.

```bash
kubectl delete -f clarus-pod.yaml
```

### What if we specify a Container's request, but not its limit?

- Update the clarus-pod.yaml like below. The Container specifies a memory request, but not a limit.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: default-memory
  namespace: resources-limits
spec:
  containers:
  - name: default-memory
    image: nginx
    resources:
      requests:
        memory: "128Mi"
```

- Create the Pod.

```bash
kubectl apply -f clarus-pod.yaml
```

- View detailed information about the Pod.

```bash
kubectl get pod default-memory --output=yaml --namespace=resources-limits
```

- The output shows that the Container's memory request is set to the value specified in the Container's configuration file. The Container's memory limit is set to 512Mi, which is the default memory limit for the namespace.

```yaml
resources:
  limits:
    cpu: "1"
    memory: 512Mi
  requests:
    cpu: 500m
    memory: 128Mi
```

- Delete the pod.

```bash
kubectl delete -f clarus-pod.yaml
```

## Part 6 - Configure Memory and CPU Quotas for a Namespace

- As we have seen in this hands-on, we can use a `LimitRange` object to restrict the memory and the cpu request for individual containers in a namespace.

- What if we want to limit the memory and the CPU request `total` for all containers running in a namespace. For this, we can use `ResourceQuota` object. We can also restrict the totals for memory and CPU limit with `ResourceQuota` object.

- Create a yaml file and name it resource-quota.yaml.

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: mem-cpu
spec:
  hard:
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
```

- Create the ResourceQuota for resources-limits namespace.

```bash
kubectl apply -f resource-quota.yaml --namespace=resources-limits
```

- View detailed information about the ResourceQuota.

```bash
kubectl get resourcequota mem-cpu --namespace=resources-limits --output=yaml
```

- The ResourceQuota places these requirements on the resources-limits namespace:

  - Every Container must have a memory request, memory limit, cpu request, and cpu limit.

  - The memory request total for all Containers must not exceed 1 GiB.

  - The memory limit total for all Containers must not exceed 2 GiB.

  - The CPU request total for all Containers must not exceed 1 cpu.

  - The CPU limit total for all Containers must not exceed 2 cpu.

- Let's create a pod. Update clarus-pod.yaml as below.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: quota-mem-cpu
  namespace: resources-limits
spec:
  containers:
  - image: nginx
    imagePullPolicy: Always
    name: quota-mem-cpu
    resources:
      limits:
        memory: "800Mi"
        cpu: "800m"
      requests:
        memory: "600Mi"
        cpu: "400m"
```

- Create the Pod.

```bash
kubectl apply -f clarus-pod.yaml
```

- Once again, view detailed information about the ResourceQuota:

```
```bash
kubectl get resourcequota mem-cpu --namespace=resources-limits --output=yaml
```

- The output shows the quota along with how much of the quota has been used. We can see that the memory and CPU requests and limits for our Pod do not exceed the quota.

```yaml
status:
  hard:
    limits.cpu: "2"
    limits.memory: 2Gi
    requests.cpu: "1"
    requests.memory: 1Gi
  used:
    limits.cpu: 800m
    limits.memory: 800Mi
    requests.cpu: 400m
    requests.memory: 600Mi
```

- We will attempt to create a second Pod. Create a file and name it clarus-pod-2.yaml.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: quota-mem-cpu-2
  namespace: resources-limits
spec:
  containers:
  - image: nginx
    imagePullPolicy: Always
    name: quota-mem-cpu-2
    resources:
      limits:
        memory: "1Gi"
        cpu: "800m"
      requests:
        memory: "700Mi"
        cpu: "400m"
```

- In the configuration file, we can see that the Pod has a memory request of 700 MiB. Notice that the sum of the used memory request and this new memory request exceeds the memory request quota. 600 MiB + 700 MiB > 1 GiB.

- Create the Pod.

```bash
kubectl apply -f clarus-pod-2.yaml
```

- The second Pod does not get created. The output shows that creating the second Pod would cause the memory request total to exceed the memory request quota.

```
Error from server (Forbidden): error when creating "clarus-pod-2.yaml": pods "quota-mem-cpu-2" is forbidden: exceeded quota: mem-cpu, requested: requests.memory=700Mi, used: requests.memory=600Mi, limited: requests.memory=1Gi
```

- Delete the pods.

```bash
kubectl delete -f clarus-pod.yaml
kubectl delete -f clarus-pod-2.yaml
```

## Part 7 - Configure Quotas for API Objects

- In kubernetes, we can restrict the number of API objects, including Pods, PersistentVolumeClaims and Services, that can be created in a namespace. 

- On this part, we will see how to configure quotas for API objects. We specify quotas in a `ResourceQuota object`.

- Let's define a ResourceQuota object. Create a yaml file name it object-quota.yaml.

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: object-quota
spec:
  hard:
    pods: "2"
    services.nodeports: "1"
    services.loadbalancers: "0"
    persistentvolumeclaims: "2"
```

- Create the Pod.

```bash
kubectl apply -f object-quota.yaml --namespace=resources-limits
```

- View detailed information about the ResourceQuota.

```bash
kubectl get resourcequota object-quota --namespace=resources-limits --output=yaml
```

- The output shows that in the resources-limits namespace, there can be at most two Pods, two PersistentVolumeClaims, one Service of type NodePort and no Services of type LoadBalancer.

```yaml
status:
  hard:
    persistentvolumeclaims: "2"
    pods: "2"
    services.loadbalancers: "0"
    services.nodeports: "1"
  used:
    persistentvolumeclaims: "0"
    pods: "0"
    services.loadbalancers: "0"
    services.nodeports: "0"
```

- Create a deployment yaml and name it quota-deploy.yaml.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:  
  namespace: resources-limits
  name: pod-quota
spec:
  selector:
    matchLabels:
      purpose: quota-demo
  replicas: 3
  template:
    metadata:
      labels:
        purpose: quota-demo
    spec:
      containers:
      - name: pod-quota
        image: nginx
```

- In the configuration file, replicas: 3 tells Kubernetes to attempt to create three Pods, all running the same application.

- Create the Deployment.

```bash
kubectl apply -f quota-deploy.yaml
```

- View detailed information about the Deployment:

```bash
kubectl get deployment pod-quota --namespace=resources-limits --output=yaml
```

- The output shows that even though the Deployment specifies three replicas, only two Pods were created because of the quota.

```yaml
spec:
  ...
  replicas: 3
...
status:
  availableReplicas: 2
...
    lastUpdateTime: "2021-04-27T16:41:08Z"
    message: 'pods "pod-quota-f8f7477d7-lfmz4" is forbidden: exceeded quota: object-quota,
      requested: pods=1, used: pods=2, limited: pods=2'
```

- Now, let's try to create Services of type LoadBalancer. Create a yaml file and name it quota-service.yaml.

```yaml
apiVersion: v1
kind: Service   
metadata:
  namespace: resources-limits
  name: quota-service
  labels:
    app: quota-service
spec:
  type: LoadBalancer
  ports:
  - port: 80  
    targetPort: 80
  selector:
    purpose: quota-demo
```

- Create the service.

```bash
kubectl apply -f quota-service.yaml
```

- The output shows that we can not create the Services of type LoadBalancer due to quota.

```bash
Error from server (Forbidden): error when creating "quota-service.yaml": services "quota-service" is forbidden: exceeded quota: object-quota, requested: services.loadbalancers=1, used: services.loadbalancers=0, limited: services.loadbalancers=0
```

- Update the quota-service.yaml and change LoadBalancer to NodePort like below.

```yaml
apiVersion: v1
kind: Service   
metadata:
  namespace: resources-limits
  name: quota-service
  labels:
    app: quota-service
spec:
  type: NodePort
  ports:
  - port: 80  
    targetPort: 80
  selector:
    purpose: quota-demo
```

- Create the service.

```bash
kubectl apply -f quota-service.yaml
```

- This time we can create the service, because there is one quota for Service of type NodePort.

Delete the deployment and service.

```bash
kubectl delete -f quota-deploy.yaml
kubectl delete -f quota-service.yaml
```
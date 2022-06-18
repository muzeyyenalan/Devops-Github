# Hands-on Docker-13 : docker logs, top, stats and diff command

Purpose of the this hands-on training is to teach students how to use docker logs, top and stats commands.

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- use docker logs, top, stats and diff commands.

## Outline

- Part 1 - Launch a Docker Machine Instance and Connect with SSH

- Part 2 - Docker Logs command

- Part 3 - Docker top and stats commands

- Part 4 - Docker diff command

## Part 1 - Launch a Docker Machine Instance and Connect with SSH

- Launch a Docker machine on Amazon Linux 2 AMI with security group allowing SSH connections using the [Cloudformation Template for Docker Machine Installation](../docker-01-installing-on-ec2-linux2/docker-installation-template.yml).

- Connect to your instance with SSH.

```bash
ssh -i .ssh/call-training.pem ec2-user@ec2-3-133-106-98.us-east-2.compute.amazonaws.com
```

## Part 2 - Docker Logs

- The docker logs command shows information logged by a running container.

- Run an nginx container.

```bash
docker container run --name ng -d -p 80:80 nginx
```

- Fetch the logs of ng container with `docker logs` command.

```bash
docker logs ng
```

- Produce logs with curl command.

```bash
curl http://<ec2-ip>
```

- Display the detailed information about logs.

```bash
docker logs --details ng 
```

- Display the timestamps of logs.

```bash
docker logs -t ng 
```

- Display the logs until a time and since a time.

```bash
docker logs --until <timestamp> ng
docker logs --since <timestamp> ng
```

- Display the last 5 lines of logs.

```bash
docker logs --tail 5 ng
```

- Follow the container logs.

```bash
docker logs -f ng
```

## Part 3 - Docker top and stats commands

- Display the running processes of a container.

```bash
docker top ng
```
- Display the resource usage statistic of container(s).

```bash
docker stats
```

- We can display a specific container's resource usage statistics.

```bash
docker stats ng
```

- We can limit the memory and cpu usage of containers. Create a new nginx container.

```bash
docker container run --name ng-2 --memory=200m -d -p 8080:80 nginx
```

- Display the resource usage statistic of containers and pay attention to the limited memory usage of containers. 

```bash
docker stats
```
- Display the information about the CPU of system.

```bash
lscpu
```

- Create a new nginx container and limit the cpu usage.

```bash
docker container run --name ng-3 --cpus=2 -d -p 8081:80 nginx
```

## Part 4 - Docker diff command

- List the changed files and directories in a container᾿s filesystem since the container was created. Three different types of change are tracked:

| Symbol | Description |
| ---    | :---        |
| A	     | A file or directory was added |
| D	     | A file or directory was deleted |
| C	     | A file or directory was changed |

- Run an ubuntu container.

```bash
$ docker run -it --name mycontainer ubuntu bash
root@468bffd23a51:/# ls
bin   dev  home  lib32  libx32  mnt  proc  run   srv  tmp  var
boot  etc  lib   lib64  media   opt  root  sbin  sys  usr
root@468bffd23a51:/# mkdir added-container
root@468bffd23a51:/# ls 
added-container  boot  etc   lib    lib64   media  opt   root  sbin  sys  usr
bin              dev   home  lib32  libx32  mnt    proc  run   srv   tmp  var
root@468bffd23a51:/# ls opt
root@468bffd23a51:/# rmdir opt
root@468bffd23a51:/# ls
added-container  boot  etc   lib    lib64   media  proc  run   srv  tmp  var
bin              dev   home  lib32  libx32  mnt    root  sbin  sys  usr
root@468bffd23a51:/# cd mnt
root@468bffd23a51:/mnt# ls
root@468bffd23a51:/mnt# touch test-file
root@468bffd23a51:/mnt# exit
exit
```

- List the changed files and directories in a container᾿s filesystem with `docker diff` command.

```bash
$ docker diff mycontainer
A /added-container
C /root
A /root/.bash_history
C /mnt
A /mnt/test-file
D /opt
```

- Remove all the containers.

```bash
docker container rm -f $(docker ps -aq)
```
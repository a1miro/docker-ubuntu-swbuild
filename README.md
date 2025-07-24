## Introduction

This Docker container is based on ubuntu:22.04@sha256:da5fdf346e5313bef2a3dd2476c0251d48103213a5e3a0cb3afbb8909f3cf50f and it can be used for building software written in C/C++, using CMake, automake/autoconfig, Bazel and Yocto Scarthgap 5.x build system. Here is the list of the most important packages and their versions:

| Tool                | Version  |
|---------------------|----------|
| gcc/g++             | 11.4     |
| clang               | 14.0.0   |
| python              | 3.10.12  |
| pip                 | 22.0.2   |
| Make                | 4.3      |
| Cmake               | 4.0.3    |
| Git                 | 2.34.1   |
| Yocto\*             | 5.0      |


Additionally it includes Microsoft VCPKG package manager for retrieving dependencies in C/C++ application development. More about VCPKG and it's integration can be found [here](https://vcpkg.io/en/). Configure the VCPKG_ROOT environment variable:

```sh
export VCPKG_ROOT="/opt/apps/vcpkg"
export PATH="${VCPKG_ROOT};${PATH}"
```

For the support of Yocto/Poky (Scarthgap 5.0) build all required packages are installed. Most of Yocto BSP vendors rely on Google repo tool for retrieving Yocto sources, wherefore it's been installed and can be accessed from inside the contrainer:

```sh
/opt/apps/repo
```
<small> Yocto\* is not installed inside the container, but container can be used to build ***Yocto*** Scarthgap 5.0 </small>


## Building and Running Docker container

Clone docker container and checkout ubuntu.22.04

```sh
git clone https://github.com/a1miro/docker-ubuntu-swbuild.git
git checkout --track origin/ubuntu.22.04
```
set the Docker build environment

```
cd docker-ubuntu-swbuild
./makeenv.sh
```

the **makeenv.sh** shell script sets environment variables are shown below and stores them in .env file
```
uid=1002
gid=1002
username=amironenko
```

this allows sharing of user credentials between the host and the docker container. Start the container build:

```
docker compose build
```

start the container in detached mode (demon)

```
docker compose up -d
```

check the container is running either using docker compose

```
docker compose ps
NAME                   IMAGE                  COMMAND                  SERVICE         CREATED       STATUS      PORTS
swbuild-ubuntu-22.04   swbuild-ubuntu-22.04   "/bin/bash -c '/etc/…"   swbuild-22.04   4 weeks ago   Up 7 days   22/tcp, 0.0.0.0:8024->8024/tcp, :::8024->8024/tcp
```

or by using ***docker ps***

```
docker ps
CONTAINER ID   IMAGE                  COMMAND                  CREATED       STATUS      PORTS                                               NAMES
9c1f9bb4e60b   swbuild-ubuntu-22.04   "/bin/bash -c '/etc/…"   4 weeks ago   Up 7 days   22/tcp, 0.0.0.0:8024->8024/tcp, :::8024->8024/tcp   swbuild-ubuntu-22.04
```

to attach to the running container, again you can either use docker compose command (please notice we use SERVICE field from ***docker compose ps*** command output) here:

```
docker compose -it -u ${USER} swbuild-22.04 /bin/bash
```

or using this docker command (we use *NAMES* field from the ***docker ps*** command output)

```
docker exec -it -u $USER swbuild-ubuntu-22.04 /bin/bash
```

You should get to the docker container bash prompt now

```
username@swbuild-2204:~$
```

## Customize the container by adding docker-compose.override.yml with similar context:

Look at the example below

```yml
services:
  swbuild-22.04:
    build:
      args: 
        username: ${username}
    volumes:
      -  /home/${username}:/mnt/host/home/${username}:rw
```
as I mentioned early .env file passed these three environment variables to the YAML

```
uid=1002
gid=1002
username=amironenko
```

we use **username** to setup Yaml uernmae argument and mount host user home folder under /mnt/host/home inside the container.

## Accessing volumes
### Windows
### Linux

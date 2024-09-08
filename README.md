

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

```
services:
    rogueddk:
        build:
            args:
                kernel_id: 5.15.0-76-generic
        volumes:
            -  /c/Users/Andrei.Mironenko/.ssh:/home/${username}/.ssh:ro
```


Customize the container by adding docker-compose.override.yml with similar context:

```
services:
    rogueddk:
        build:
            args:
                kernel_id: 5.15.0-76-generic
        volumes:
            -  /c/Users/Andrei.Mironenko/.ssh:/home/${username}/.ssh:ro
```

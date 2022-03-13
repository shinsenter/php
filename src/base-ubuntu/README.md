# shinsenter/s6-ubuntu

Ubuntu 20.04 (Focal) Docker base image with s6-overlay v3 and OpenSSL included.

https://hub.docker.com/r/shinsenter/s6-ubuntu

[![Docker Pulls](https://img.shields.io/docker/pulls/shinsenter/s6-ubuntu)](https://hub.docker.com/r/shinsenter/s6-ubuntu) [![Docker Image Size](https://img.shields.io/docker/image-size/shinsenter/s6-ubuntu/latest?label=shinsenter%2Fs6-ubuntu)](https://hub.docker.com/r/shinsenter/s6-ubuntu/tags)

* * *

## About this project

Ubuntu 20.04 (Focal) Docker base image with [s6-overlay v3](https://github.com/just-containers/s6-overlay/tree/v3) and [OpenSSL](https://github.com/openssl/openssl) included.

The [s6-overlay](https://github.com/just-containers/s6-overlay) was built specifically for the lifecycle of containers, giving you a more accurate way of bringing containers down and monitoring their health.

See a great explanation called ["The Docker Way?"](https://github.com/just-containers/s6-overlay#the-docker-way) by the s6-overlay team for an excellent explaination.

## Usage

### Docker Pull command

```bash
docker pull shinsenter/s6-ubuntu
```

### Docker Compose example

```yml
version: '3'
services:
  my-container:
    image: shinsenter/s6-ubuntu:latest
    environment:
      TZ: UTC
```

View more image tags at [shinsenter/s6-ubuntu/tags](https://hub.docker.com/r/shinsenter/s6-ubuntu/tags).

## Customize your own image

Dockerfile example for building your own Docker image extending this image.

```Dockerfile
FROM shinsenter/s6-ubuntu

# Control your timezone
ENV TZ="UTC"

# sets GID and UID
ENV PUID=9999
ENV PGID=9999
ENV WEBHOME="/var/www/html"

# sets the working directory
WORKDIR $WEBHOME
```

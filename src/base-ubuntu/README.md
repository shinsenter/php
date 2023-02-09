# shinsenter/s6-ubuntu

📦 Ubuntu + OpenSSL + s6-overlay v3 Docker base images.

> 🔗 https://docker.shin.company/s6-ubuntu

[![Docker Pulls](https://img.shields.io/docker/pulls/shinsenter/s6-ubuntu)](https://docker.shin.company/s6-ubuntu) [![Docker Image Size](https://img.shields.io/docker/image-size/shinsenter/s6-ubuntu/latest?label=shinsenter%2Fs6-ubuntu)](https://docker.shin.company/s6-ubuntu)

* * *

## About this project

Are you tired of using the same old, basic Docker base images? Look no further than this repository, where you'll find the latest stable versions of [Ubuntu](https://ubuntu.com) with added features for optimal container management. Not only do these images include the powerful [s6-overlay v3](https://github.com/just-containers/s6-overlay/tree/v3), specifically designed for the lifecycle of containers, but they also come with [OpenSSL](https://github.com/openssl/openssl) included.

Want to know more about why s6-overlay is the ultimate tool for container management? Check out the [explanation](https://github.com/just-containers/s6-overlay#the-docker-way) by the s6-overlay team.

And the best part? These images are actively maintained, ensuring that you're always using the most up-to-date version. Upgrade your Docker containers with ease.

## Container OS

Stay ahead of the game by using the following versions of Ubuntu Docker images that are actively being updated:

- [22.04](https://docker.shin.company/s6-ubuntu/tags?name=22.04) ([Jammy](https://docker.shin.company/s6-ubuntu/tags?name=jammy), [latest](https://docker.shin.company/s6-ubuntu/tags?name=latest))
- [20.04](https://docker.shin.company/s6-ubuntu/tags?name=20.04) ([Focal](https://docker.shin.company/s6-ubuntu/tags?name=focal))

## Usage

### Docker Pull command

```bash
docker pull shinsenter/s6-ubuntu:latest
```

or

```bash
docker pull shinsenter/s6-ubuntu:jammy
```

or

```bash
docker pull shinsenter/s6-ubuntu:22.04
```

> View more image tags at [shinsenter/s6-ubuntu/tags](https://docker.shin.company/s6-ubuntu/tags).

### Access to your container

Just open a terminal and run below command to access to your container:

```bash
docker exec -it <container_id> /bin/bash
```

### Docker Run command

```bash
docker run --rm [run options] shinsenter/s6-ubuntu <your_command>
```

For example:

```bash
docker run --rm -v $(pwd):/var/www/html -e PUID=$(id -u) -e PGID=$(id -g) shinsenter/s6-ubuntu env
```

## Customize Your Docker Image

Easily change container configurations and tailor your image to your specific needs by utilizing pre-defined Docker environment variables.

Look no further than this `Dockerfile` sample for building your own custom image by extending the base image provided here.

> Want to learn more about how to create the ultimate custom image? Check out the [Dockerfile documentation](https://docs.docker.com/engine/reference/builder) and start building today.

```Dockerfile
FROM shinsenter/s6-ubuntu

# sets s6-overlay entrypoint
ENTRYPOINT ["/init"]

# Control your timezone
ENV TZ="UTC"

# sets GID and UID
ENV PUID=9999
ENV PGID=9999

# set ENABLE_CRONTAB=true to enable crontab
ENV ENABLE_CRONTAB=false
```

Then run below command to build your Docker image.

```bash
docker build [build options] - < Dockerfile
```

## Docker Compose example

Create an empty directory for a new project and place in the directory a `docker-compose.yml` file with below content.

> Learn more about [Docker Compose](https://docs.docker.com/compose).

```yml
version: '3'
services:
  s6-ubuntu-app:
    image: shinsenter/s6-ubuntu:latest
    environment:
      TZ: UTC
      PUID: ${UID:-9999}
      PGID: ${GID:-9999}
```

Then run below command to start containers.

```bash
docker-compose up -d
```

## Supported platforms

Currently, the supported architectures are:

- linux/amd64
- linux/arm/v7
- linux/arm64/v8
- linux/ppc64le
- linux/s390x

> You do not need to use a platform-specific tag (although you can), Docker will automatically choose the appropriate architecture.
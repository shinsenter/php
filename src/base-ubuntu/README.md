# shinsenter/s6-ubuntu

📦 Ubuntu + OpenSSL + s6-overlay v3 Docker base images.

> 🔗 https://docker.shin.company/s6-ubuntu

[![Docker Pulls](https://img.shields.io/docker/pulls/shinsenter/s6-ubuntu)](https://docker.shin.company/s6-ubuntu) [![Docker Image Size](https://img.shields.io/docker/image-size/shinsenter/s6-ubuntu/latest?label=shinsenter%2Fs6-ubuntu)](https://docker.shin.company/s6-ubuntu)

* * *

## About this project

Latest stable [Ubuntu](https://ubuntu.com) docker base images with [s6-overlay v3](https://github.com/just-containers/s6-overlay/tree/v3) and [OpenSSL](https://github.com/openssl/openssl) included.

> The [s6-overlay](https://github.com/just-containers/s6-overlay) was built specifically for the lifecycle of containers, giving you a more accurate way of bringing containers down and monitoring their health. See a great explanation called ["The Docker Way?"](https://github.com/just-containers/s6-overlay#the-docker-way) by the s6-overlay team for an excellent explaination.

These images are actively maintained.

## Container OS

The following versions of Ubuntu are being actively updated:

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

## Customize Docker image

Here below is a sample `Dockerfile` for building your own Docker image extending this image. You also can add more [pre-defined Docker's ENV settings](https://code.shin.company/php#customize-docker-image) to change PHP-FPM behavior without copying configuration files to your containers.

> Learn more about [Dockerfile](https://docs.docker.com/engine/reference/builder).

You can easily change container configurations by using pre-defined Docker's environment variables.

```Dockerfile
FROM shinsenter/s6-ubuntu

# sets s6-overlay entrypoint
ENTRYPOINT ["/init"]

# Control your timezone
ENV TZ="UTC"

# sets GID and UID
ENV PUID=9999
ENV PGID=9999
ENV WEBHOME="/var/www/html"

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
  my-container:
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
- linux/riscv64
- linux/s390x

> You do not need to use a platform-specific tag (although you can), Docker will automatically choose the appropriate architecture.
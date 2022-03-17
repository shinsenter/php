# shinsenter/phpfpm-nginx

🧭 Production-ready Docker images for PHP applications, powered by Nginx web server.

https://hub.docker.com/r/shinsenter/phpfpm-nginx

[![Docker Pulls](https://img.shields.io/docker/pulls/shinsenter/phpfpm-nginx)](https://hub.docker.com/r/shinsenter/phpfpm-nginx) [![Docker Image Size](https://img.shields.io/docker/image-size/shinsenter/phpfpm-nginx/latest?label=shinsenter%2Fphpfpm-nginx)](https://hub.docker.com/r/shinsenter/phpfpm-nginx/tags)

* * *

## About this project

Production-ready Docker images for PHP applications, powered by [Nginx web server](https://nginx.org/).

Built on top of [shinsenter/php](https://hub.docker.com/r/shinsenter/php) Docker images.

## Usage

### Docker Pull command

```bash
docker pull shinsenter/phpfpm-nginx
```

### Docker Compose example

```yml
version: '3'
services:
  my-container:
    image: shinsenter/phpfpm-nginx:latest
    volumes:
      - ./my-website:/var/www/html
    environment:
      TZ: UTC
    ports:
      - "80:80"
      - "443:443"
```

View more image tags at [shinsenter/phpfpm-nginx/tags](https://hub.docker.com/r/shinsenter/phpfpm-nginx/tags).

## Customize your own image

Dockerfile example for building your own Docker image extending this image.

```Dockerfile
FROM shinsenter/phpfpm-nginx

# Control your timezone
ENV TZ="UTC"

# sets GID and UID
ENV PUID=9999
ENV PGID=9999

# Sets the directory from which Nginx will serve files
ENV WEBHOME="/var/www/html"

# Set Nginx root folder within $WEBHOME
# E.g: NGINX_DOCUMENT_ROOT="/public"
ENV NGINX_DOCUMENT_ROOT=""

# Set to "true" to fix permission for whole $WEBHOME
ENV FIX_WEBHOME_PERMISSION="false"

# sets the working directory
WORKDIR $WEBHOME

# ==========================================================

# Please check https://hub.docker.com/r/shinsenter/php
# for more details of PHP environment variables.
```

## Supported platforms

Currently, the supported architectures are:

- linux/amd64
- linux/arm/v7
- linux/arm64
- linux/ppc64le

You do not need to use a platform-specific tag (although you can), Docker will automatically choose the appropriate architecture.
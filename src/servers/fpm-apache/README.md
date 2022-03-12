# shinsenter/phpfpm-apache

🧭 Production-ready Docker images for PHP applications, powered by Apache2 web server.

https://hub.docker.com/r/shinsenter/phpfpm-apache

[![Docker Pulls](https://img.shields.io/docker/pulls/shinsenter/phpfpm-apache)](https://hub.docker.com/r/shinsenter/phpfpm-apache) [![Docker Image Size](https://img.shields.io/docker/image-size/shinsenter/phpfpm-apache?label=shinsenter%2Fphpfpm-apache)](https://hub.docker.com/r/shinsenter/phpfpm-apache/tags)

* * *

## About this project

Production-ready Docker images for PHP applications, powered by [Apache2 web server](https://httpd.apache.org).

Built on top of [shinsenter/php](https://hub.docker.com/r/shinsenter/php) Docker images.

## Usage

### Docker Pull command

```bash
docker pull shinsenter/phpfpm-apache
```

### Docker Compose example

```yml
version: '3'
services:
  my-container:
    image: shinsenter/phpfpm-apache:latest
    volumes:
      - ./my-website:/var/www/html
    environment:
      TZ: UTC
    ports:
      - "80:80"
      - "443:443"
```

View more image tags at [shinsenter/phpfpm-apache/tags](https://hub.docker.com/r/shinsenter/phpfpm-apache/tags).

## Customize your own image

Dockerfile example for building your own Docker image extending this image.

```Dockerfile
FROM shinsenter/phpfpm-apache

# Control your timezone
ENV TZ="UTC"

# sets GID and UID
ENV PUID=9999
ENV PGID=9999

# Sets the directory from which Apache will serve files
ENV WEBHOME="/var/www/html"

# Set Apache root folder within $WEBHOME
# E.g: APACHE_DOCUMENT_ROOT="/public"
ENV APACHE_DOCUMENT_ROOT=""

# Set to "true" to fix permission for whole $WEBHOME
ENV FIX_WEBHOME_PERMISSION="false"

# sets the working directory
WORKDIR $WEBHOME

# ==========================================================

# Sets the limit on the number of connections
# that an individual child server process will handle
ENV APACHE_MAX_CONNECTIONS_PER_CHILD="0"

# Sets the limit on the number of simultaneous requests that will be served
ENV APACHE_MAX_REQUEST_WORKERS="150"

# Maximum number of idle threads
ENV APACHE_MAX_SPARE_THREADS="75"

# Minimum number of idle threads to handle request spikes
ENV APACHE_MIN_SPARE_THREADS="10"

# Sets the number of child server processes created on startup
ENV APACHE_START_SERVERS="2"

# Set the maximum configured value for ThreadsPerChild
# for the lifetime of the Apache httpd process
ENV APACHE_THREAD_LIMIT="64"

# This directive sets the number of threads created by each child process
ENV APACHE_THREADS_PER_CHILD="25"

# ==========================================================

# Please check https://hub.docker.com/r/shinsenter/php
# for more details of PHP environment variables.
```
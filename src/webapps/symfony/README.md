# shinsenter/symfony

Start creating beautiful Symfony websites with ease. Powered by shinsenter/php.

https://hub.docker.com/r/shinsenter/symfony

[![Docker Pulls](https://img.shields.io/docker/pulls/shinsenter/symfony)](https://hub.docker.com/r/shinsenter/symfony) [![Docker Image Size](https://img.shields.io/docker/image-size/shinsenter/symfony/latest?label=shinsenter%2Fsymfony)](https://hub.docker.com/r/shinsenter/symfony/tags)

* * *

## About this project

Start creating beautiful Symfony websites with ease.

Powered by [shinsenter/php](https://hub.docker.com/r/shinsenter/php).

## Usage

### Docker Pull command

```bash
docker pull shinsenter/symfony
```

### Docker Compose example

```yml
version: '3'
services:
  my-container:
    image: shinsenter/symfony:latest
    volumes:
      - ./my-website:/var/www/html
    environment:
      TZ: UTC
    ports:
      - "80:80"
      - "443:443"
```

View more image tags at [shinsenter/symfony/tags](https://hub.docker.com/r/shinsenter/symfony/tags).

## Customize your own image

Dockerfile example for building your own Docker image extending this image.

```Dockerfile
FROM shinsenter/symfony

# Control your timezone
ENV TZ="UTC"

# sets GID and UID
ENV PUID=9999
ENV PGID=9999
ENV WEBHOME="/var/www/html"

# sets the working directory
WORKDIR $WEBHOME

# ==========================================================

# Set to "true" to install packages for development purposes
ENV SYMFONY_INSTALL_DEVKIT=false

# ==========================================================

# Please check https://hub.docker.com/r/shinsenter/php
# for more details of PHP environment variables.
```
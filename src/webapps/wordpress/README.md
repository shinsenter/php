# shinsenter/wordpress

Start creating beautiful Wordpress websites with ease. Powered by shinsenter/php.

https://hub.docker.com/r/shinsenter/wordpress

[![Docker Pulls](https://img.shields.io/docker/pulls/shinsenter/wordpress)](https://hub.docker.com/r/shinsenter/wordpress) [![Docker Image Size](https://img.shields.io/docker/image-size/shinsenter/wordpress/latest?label=shinsenter%2Fwordpress)](https://hub.docker.com/r/shinsenter/wordpress/tags)

* * *

## About this project

Start creating beautiful Wordpress websites with ease.

Powered by [shinsenter/php](https://hub.docker.com/r/shinsenter/php).

## Usage

### Docker Pull command

```bash
docker pull shinsenter/wordpress
```

### Docker Compose example

```yml
version: '3'
services:
  my-container:
    image: shinsenter/wordpress:latest
    volumes:
      - ./my-website:/var/www/html
    environment:
      TZ: UTC
    ports:
      - "80:80"
      - "443:443"
```

View more image tags at [shinsenter/wordpress/tags](https://hub.docker.com/r/shinsenter/wordpress/tags).

## Customize your own image

Dockerfile example for building your own Docker image extending this image.

```Dockerfile
FROM shinsenter/wordpress

# Control your timezone
ENV TZ="UTC"

# sets GID and UID
ENV PUID=9999
ENV PGID=9999

# sets web server root path
ENV WEBHOME="/var/www/html"

# sets the working directory
WORKDIR $WEBHOME

# ==========================================================

# the locale for a fresh Wordpress
ENV WORDPRESS_LOCALE="en_US"

# ==========================================================

# recommended settings
ENV PHP_ERROR_REPORTING="E_ALL & ~E_DEPRECATED & ~E_STRICT & ~E_WARNING"
ENV PHP_MAX_EXECUTION_TIME=300
ENV PHP_POST_MAX_SIZE=100M
ENV PHP_UPLOAD_MAX_FILE_SIZE=10M

# Please check https://hub.docker.com/r/shinsenter/php
# for more details of PHP environment variables.

# Please check https://hub.docker.com/r/shinsenter/phpfpm-apache
# for more details of Apache environment variables.
```

## Supported platforms

Currently, the supported architectures are:

- linux/amd64
- linux/arm/v7
- linux/arm64
- linux/ppc64le

You do not need to use a platform-specific tag (although you can), Docker will automatically choose the appropriate architecture.
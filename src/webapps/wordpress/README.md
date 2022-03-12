# shinsenter/wordpress

Start creating beautiful Wordpress websites with ease. Powered by shinsenter/php.

https://hub.docker.com/r/shinsenter/wordpress

[![Docker Pulls](https://img.shields.io/docker/pulls/shinsenter/wordpress)](https://hub.docker.com/r/shinsenter/wordpress) [![Docker Image Size](https://img.shields.io/docker/image-size/shinsenter/wordpress?label=shinsenter%2Fwordpress)](https://hub.docker.com/r/shinsenter/wordpress/tags)

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
ENV APACHE_DOCUMENT_ROOT=""

# sets the working directory
WORKDIR $WEBHOME

# ==========================================================

# The locale for a fresh Wordpress
ENV WORDPRESS_LOCALE="en_US"

# ==========================================================

# Please check https://hub.docker.com/r/shinsenter/php
# for more details of PHP environment variables.
```
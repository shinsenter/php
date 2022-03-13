# shinsenter/laravel

Start creating beautiful Laravel websites with ease. Powered by shinsenter/php.

https://hub.docker.com/r/shinsenter/laravel

[![Docker Pulls](https://img.shields.io/docker/pulls/shinsenter/laravel)](https://hub.docker.com/r/shinsenter/laravel) [![Docker Image Size](https://img.shields.io/docker/image-size/shinsenter/laravel/latest?label=shinsenter%2Flaravel)](https://hub.docker.com/r/shinsenter/laravel/tags)

* * *

## About this project

Start creating beautiful Laravel websites with ease.

Powered by [shinsenter/php](https://hub.docker.com/r/shinsenter/php).

## Usage

### Docker Pull command

```bash
docker pull shinsenter/laravel
```

### Docker Compose example

```yml
version: '3'
services:
  my-container:
    image: shinsenter/laravel:latest
    volumes:
      - ./my-website:/var/www/html
    environment:
      TZ: UTC
    ports:
      - "80:80"
      - "443:443"
```

View more image tags at [shinsenter/laravel/tags](https://hub.docker.com/r/shinsenter/laravel/tags).

## Customize your own image

Dockerfile example for building your own Docker image extending this image.

```Dockerfile
FROM shinsenter/laravel

# Control your timezone
ENV TZ="UTC"

# sets GID and UID
ENV PUID=9999
ENV PGID=9999
ENV WEBHOME="/var/www/html"

# sets web server root path
ENV WEBHOME="/var/www/html"
ENV NGINX_DOCUMENT_ROOT="/public"

# sets the working directory
WORKDIR $WEBHOME

# ==========================================================

# Optimize and cache all config, views, routes
ENV LARAVEL_AUTO_OPTIMIZE=true

# Create symlinks to the storage folder
ENV LARAVEL_LINK_STORAGE=true

# Run Laravel migrations (for development purposese)
ENV LARAVEL_AUTO_MIGRATION=false

# ==========================================================

# Please check https://hub.docker.com/r/shinsenter/php
# for more details of PHP environment variables.
```
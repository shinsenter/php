# shinsenter/codeigniter4

Start creating beautiful CodeIgniter 4 websites with ease. Powered by shinsenter/php.

https://hub.docker.com/r/shinsenter/codeigniter4

[![Docker Pulls](https://img.shields.io/docker/pulls/shinsenter/codeigniter4)](https://hub.docker.com/r/shinsenter/codeigniter4) [![Docker Image Size](https://img.shields.io/docker/image-size/shinsenter/codeigniter4/latest?label=shinsenter%2Fcodeigniter4)](https://hub.docker.com/r/shinsenter/codeigniter4/tags)

* * *

## About this project

Start creating beautiful CodeIgniter 4 websites with ease.

Powered by [shinsenter/php](https://hub.docker.com/r/shinsenter/php).

## Usage

### Docker Pull command

```bash
docker pull shinsenter/codeigniter4
```

### Docker Compose example

```yml
version: '3'
services:
  my-container:
    image: shinsenter/codeigniter4:latest
    volumes:
      - ./my-website:/var/www/html
    environment:
      TZ: UTC
    ports:
      - "80:80"
      - "443:443"
```

View more image tags at [shinsenter/codeigniter4/tags](https://hub.docker.com/r/shinsenter/codeigniter4/tags).

## Customize your own image

Dockerfile example for building your own Docker image extending this image.

```Dockerfile
FROM shinsenter/codeigniter4

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
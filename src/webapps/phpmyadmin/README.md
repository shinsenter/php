# shinsenter/phpmyadmin

The World's smallest Ubuntu-based Docker image for phpMyAdmin. Powered by shinsenter/php.

https://hub.docker.com/r/shinsenter/phpmyadmin

[![Docker Pulls](https://img.shields.io/docker/pulls/shinsenter/phpmyadmin)](https://hub.docker.com/r/shinsenter/phpmyadmin) [![Docker Image Size](https://img.shields.io/docker/image-size/shinsenter/phpmyadmin/latest?label=shinsenter%2Fphpmyadmin)](https://hub.docker.com/r/shinsenter/phpmyadmin/tags)

* * *

## About this project

The World's smallest Ubuntu-based Docker image for phpMyAdmin.

Powered by [shinsenter/php](https://hub.docker.com/r/shinsenter/php).

## Usage

### Docker Pull command

```bash
docker pull shinsenter/phpmyadmin
```

### Docker Compose example

```yml
version: '3'
services:
  my-container:
    image: shinsenter/phpmyadmin:latest
    volumes:
      - ./my-website:/var/www/html
    environment:
      TZ: UTC
    ports:
      - "80:80"
      - "443:443"
```

View more image tags at [shinsenter/phpmyadmin/tags](https://hub.docker.com/r/shinsenter/phpmyadmin/tags).

## Customize your own image

Dockerfile example for building your own Docker image extending this image.

```Dockerfile
FROM shinsenter/phpmyadmin

# Control your timezone
ENV TZ="UTC"

# sets GID and UID
ENV PUID=9999
ENV PGID=9999

# sets web server root path
ENV WEBHOME="/var/www/html"
ENV NGINX_DOCUMENT_ROOT=""

# sets the working directory
WORKDIR $WEBHOME

# ==========================================================

ENV PMA_HOST=mysql
ENV PMA_USER=
ENV PMA_PASSWORD=

# ENV PMA_ARBITRARY=1
# ENV PMA_HOSTS=
# ENV PMA_VERBOSE=
# ENV PMA_VERBOSES=
# ENV PMA_PORT=
# ENV PMA_PORTS=
# ENV PMA_SOCKET=
# ENV PMA_SOCKETS=

# ENV PMA_ABSOLUTE_URI=
# ENV PMA_CONTROLHOST=
# ENV PMA_CONTROLPORT=
# ENV PMA_PMADB=
# ENV PMA_CONTROLUSER=
# ENV PMA_CONTROLPASS=
# ENV PMA_QUERYHISTORYDB=
# ENV PMA_QUERYHISTORYMAX=

# ==========================================================

# Please check https://hub.docker.com/r/shinsenter/php
# for more details of PHP environment variables.
```
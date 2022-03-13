# shinsenter/php

🧭 Production-ready Docker images for PHP applications, support CLI and standalone web servers.

https://hub.docker.com/r/shinsenter/php

[![Docker Pulls](https://img.shields.io/docker/pulls/shinsenter/php)](https://hub.docker.com/r/shinsenter/php) [![Docker Image Size](https://img.shields.io/docker/image-size/shinsenter/php/latest?label=shinsenter%2Fphp)](https://hub.docker.com/r/shinsenter/php/tags) [![Publish Images (shinsenter/php)](https://github.com/shinsenter/php/actions/workflows/publish-images.yml/badge.svg?branch=main)](https://github.com/shinsenter/php/actions/workflows/publish-images.yml)

* * *

## About this project

- Tired of waiting around for Docker images to build before you can start your website?
- Tired of customizing modules from official docker php images, or your docker image after installing more modules becomes too big?
- Tired of installing web sevrers like Apache or Nginx to run your PHP applications in the browser?

Not only you, but I also had those concerns when building environments for PHP applications. These jobs are quite boring and time consuming.

Therefore, based on my many years of experience, I created this project to help you quickly build an environment to run your PHP applications (regardless of whether it is a production or development environment).

Let's check it out!!

## Container OS

This project is built on top of my Docker base image, which is Ubuntu 20.04 (Focal) with s6-overlay v3 and OpenSSL included. Learn more at: [shinsenter/s6-ubuntu](https://hub.docker.com/r/shinsenter/s6-ubuntu).

## Usage

### Docker Pull command

```bash
docker pull shinsenter/php:${PHP_VERSION}-${PHP_VARIATION}
```

### Docker Compose example

```yml
version: '3'
services:
  my-container:
    image: shinsenter/php:${PHP_VERSION}-${PHP_VARIATION}
```

View more image tags at [shinsenter/php/tags](https://hub.docker.com/r/shinsenter/php/tags).

### Available PHP modules

```
apcu
bcmath
calendar
ctype
curl
dom
exif
ffi
fileinfo
ftp
gd
gettext
gmp
iconv
igbinary
intl
mbstring
mysqli
mysqlnd
opcache
pdo
pdo_mysql
pdo_sqlite
phar
posix
readline
redis
shmop
simplexml
soap
sockets
sqlite3
sysvmsg
sysvsem
sysvshm
tokenizer
xml
xmlreader
xmlwriter
xsl
zip
```

### Install more packages

Just open a terminal within your container:

```bash
docker exec -it <container_id> /bin/bash
```

Then type these command:

```bash
apt-update && apt-install <package_name>
```

## Available images

### PHP version

- [`shinsenter/php:7.4`](https://hub.docker.com/r/shinsenter/php/tags?page=1&name=7.4) <br/> [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/shinsenter/php/7.4?label=shinsenter%2Fphp%3A7.4)](https://hub.docker.com/r/shinsenter/php/tags?page=1&name=7.4)
- [`shinsenter/php:8.0`](https://hub.docker.com/r/shinsenter/php/tags?page=1&name=8.0) <br/> [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/shinsenter/php/8.0?label=shinsenter%2Fphp%3A8.0)](https://hub.docker.com/r/shinsenter/php/tags?page=1&name=8.0)
- [`shinsenter/php:8.1`](https://hub.docker.com/r/shinsenter/php/tags?page=1&name=8.1) <br/> [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/shinsenter/php/8.1?label=shinsenter%2Fphp%3A8.1)](https://hub.docker.com/r/shinsenter/php/tags?page=1&name=8.1)

### Image variations

- [`shinsenter/php:${PHP_VERSION}-cli`](https://hub.docker.com/r/shinsenter/php/tags?page=1&name=cli) <br/> [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/shinsenter/php/cli?label=shinsenter%2Fphp%3Acli)](https://hub.docker.com/r/shinsenter/php/tags?page=1&name=cli)
- [`shinsenter/php:${PHP_VERSION}-fpm`](https://hub.docker.com/r/shinsenter/php/tags?page=1&name=fpm) <br/> [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/shinsenter/php/fpm?label=shinsenter%2Fphp%3Afpm)](https://hub.docker.com/r/shinsenter/php/tags?page=1&name=fpm)

### Images for Web applications
- [`shinsenter/phpfpm-apache`](https://hub.docker.com/r/shinsenter/phpfpm-apache/tags)<br/> [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/shinsenter/phpfpm-apache/latest?label=shinsenter%2Fphpfpm-apache)](https://hub.docker.com/r/shinsenter/phpfpm-apache/tags)
- [`shinsenter/phpfpm-nginx`](https://hub.docker.com/r/shinsenter/phpfpm-nginx/tags)<br/> [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/shinsenter/phpfpm-nginx/latest?label=shinsenter%2Fphpfpm-nginx)](https://hub.docker.com/r/shinsenter/phpfpm-nginx/tags)

### Images for popular PHP projects

- [`shinsenter/wordpress`](https://hub.docker.com/r/shinsenter/wordpress/tags)<br/> [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/shinsenter/wordpress/latest?label=shinsenter%2Fwordpress)](https://hub.docker.com/r/shinsenter/wordpress/tags)
- [`shinsenter/phpmyadmin`](https://hub.docker.com/r/shinsenter/phpmyadmin/tags)<br/> [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/shinsenter/phpmyadmin/latest?label=shinsenter%2Fphpmyadmin)](https://hub.docker.com/r/shinsenter/phpmyadmin/tags)
- [`shinsenter/laravel`](https://hub.docker.com/r/shinsenter/laravel/tags)<br/> [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/shinsenter/laravel/latest?label=shinsenter%2Flaravel)](https://hub.docker.com/r/shinsenter/laravel/tags)
- [`shinsenter/codeigniter4`](https://hub.docker.com/r/shinsenter/codeigniter4/tags)<br/> [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/shinsenter/codeigniter4/latest?label=shinsenter%2Fcodeigniter4)](https://hub.docker.com/r/shinsenter/codeigniter4/tags)
- [`shinsenter/symfony`](https://hub.docker.com/r/shinsenter/symfony/tags)<br/> [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/shinsenter/symfony/latest?label=shinsenter%2Fsymfony)](https://hub.docker.com/r/shinsenter/symfony/tags)

## Customize your own image

Dockerfile example for building your own Docker image extending one of those images.

```Dockerfile
# change the PHP_VERSION and PHP_VARIATION as your need
ARG PHP_VERSION=8.1
ARG PHP_VARIATION=fpm-nginx

# extends from base image
FROM shinsenter/php:${PHP_VERSION}-${PHP_VARIATION}

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

# you may want to install some PHP modules
# e.g: this block will install sorl and swoole modules
RUN apt-update \
    && apt-install \
        php${PHP_VERSION}-solr \
        php${PHP_VERSION}-swoole \
    && apt-cleanup

# ==========================================================

# Server that should relay emails for MSMTP
ENV MSMTP_RELAY_SERVER_HOSTNAME="mailhog"

# Port the SMTP server is listening on
ENV MSMTP_RELAY_SERVER_PORT="1025"

# ==========================================================

# Show PHP errors on screen
ENV PHP_DISPLAY_ERRORS="On"

# Set PHP error reporting level
ENV PHP_ERROR_REPORTING="E_ALL & ~E_DEPRECATED & ~E_STRICT & ~E_WARNING"

# Set the maximum time in seconds a script is allowed
# to run before it is terminated by the parser
ENV PHP_MAX_EXECUTION_TIME="99"

# Set the maximum amount of memory in bytes that a script is allowed to allocate
ENV PHP_MEMORY_LIMIT="256M"

# Sets max size of post data allowed
ENV PHP_POST_MAX_SIZE="100M"

# The maximum size of an uploaded file
ENV PHP_UPLOAD_MAX_FILE_SIZE="100M"

# Set the name of your PHP-FPM pool
# (helpful when running multiple sites on a single server)
ENV PHP_POOL_NAME="www"

# ==========================================================

# Choose how the process manager will control the number of child processes
ENV PHP_PM_CONTROL="ondemand"

# The number of child processes to be created when pm is set to static
# and the maximum number of child processes to be created when pm is set to dynamic
ENV PHP_PM_MAX_CHILDREN="28"

# The desired maximum number of idle server processes
ENV PHP_PM_MAX_SPARE_SERVERS="21"

# The desired minimum number of idle server processes
ENV PHP_PM_MIN_SPARE_SERVERS="7"

# The number of child processes created on startup
ENV PHP_PM_START_SERVERS="7"

# ==========================================================

# The amount of memory used to store interned strings, in megabytes.
ENV PHP_OPCACHE_INTERNED_STRINGS_BUFFER="8"

# The maximum number of keys (and therefore scripts) in the OPcache hash table
ENV PHP_OPCACHE_MAX_ACCELERATED_FILES="1048793"

# The size of the shared memory storage used by OPcache, in megabytes
ENV PHP_OPCACHE_MEMORY_CONSUMPTION="128"

# This directive facilitates to let the preloading to be run as another user
ENV PHP_OPCACHE_PRELOAD_USER="webuser"

# Specifies a PHP script that is going to be compiled and executed at start-up
ENV PHP_OPCACHE_PRELOAD=

# How often to check script timestamps for updates, in seconds
ENV PHP_OPCACHE_REVALIDATE_FREQ="2"

# If disabled, existing cached files using the same include_path will be reused
ENV PHP_OPCACHE_REVALIDATE_PATH="0"

# If disabled, all documentation comments will be discarded
# from the opcode cache to reduce the size of the optimised code
ENV PHP_OPCACHE_SAVE_COMMENTS="1"

# If enabled, OPcache will check for updated scripts
# every opcache.revalidate_freq seconds
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="1"
```

## Thank you [@serversideup](https://github.com/serversideup)

This project is inspired by the [serversideup/docker-php](https://github.com/serversideup/docker-php) project, I love it.

However the owners seem to be quite busy updating their projects, so I made my own version.
# shinsenter/php

📦 (PHP) Ubuntu + PHP-FPM + Nginx/Apache2 Docker images with plenty of common and useful extensions.

> 🔗 https://docker.shin.company/php

[![Docker Pulls](https://img.shields.io/docker/pulls/shinsenter/php)](https://docker.shin.company/php) [![Docker Image Size](https://img.shields.io/docker/image-size/shinsenter/php/latest?label=shinsenter%2Fphp)](https://docker.shin.company/php/tags) [![Publish Images (shinsenter/php)](https://code.shin.company/php/actions/workflows/build-v2.yml/badge.svg?branch=main)](https://code.shin.company/php/actions/workflows/build-v2.yml)

[![shinsenter/php](https://repository-images.githubusercontent.com/458053748/24e848e1-c0fc-4893-b2b9-f7dbfad263f3)](https://docker.shin.company/php)

* * *

## About this project

I have had those concerns when building environments for PHP applications.

- Tired of waiting around for Docker images to build.
- Tired of customizing modules from official Docker PHP images, and Docker image after installing more modules becomes too big.
- Tired of installing web server like Apache or Nginx on the top of PHP, in order to run a PHP application on browser.

Above jobs are quite boring and time consuming, am I right?

Therefore, based on my many years of experience, I created this project to help you quickly build an environment to run your PHP applications (regardless of whether it is a production or development environment).

I hope you find this project helpful, please consider [supporting my works](https://code.shin.company/php/blob/main/SPONSOR.md) if you like it.

> ### Special thanks
>
> This project is inspired by the [serversideup/docker-php](https://github.com/serversideup/docker-php) project, I love it.
>
> However the owners seem to be quite busy updating their projects, so I made my own version.

Let's check it out!

## Container OS

This project is built on top of my Docker base image, which is Ubuntu 22.04 (Jammy) with [s6-overlay v3](https://docker.shin.company/s6-overlay) and OpenSSL included.

> Learn more:
> - [![`shinsenter/s6-overlay`](https://img.shields.io/docker/image-size/shinsenter/s6-overlay/latest?label=shinsenter%2Fs6-overlay)](https://docker.shin.company/s6-overlay)
> - [![`shinsenter/s6-ubuntu`](https://img.shields.io/docker/image-size/shinsenter/s6-ubuntu/latest?label=shinsenter%2Fs6-ubuntu)](https://docker.shin.company/s6-ubuntu)

## Available images

These images are actively maintained.

### PHP versions

- [![`shinsenter/php:7.3`](https://img.shields.io/docker/image-size/shinsenter/php/7.3?label=shinsenter%2Fphp%3A7.3)](https://docker.shin.company/php/tags?page=1&name=7.3)
- [![`shinsenter/php:7.4`](https://img.shields.io/docker/image-size/shinsenter/php/7.4?label=shinsenter%2Fphp%3A7.4)](https://docker.shin.company/php/tags?page=1&name=7.4)
- [![`shinsenter/php:8.0`](https://img.shields.io/docker/image-size/shinsenter/php/8.0?label=shinsenter%2Fphp%3A8.0)](https://docker.shin.company/php/tags?page=1&name=8.0)
- [![`shinsenter/php:8.1`](https://img.shields.io/docker/image-size/shinsenter/php/8.1?label=shinsenter%2Fphp%3A8.1)](https://docker.shin.company/php/tags?page=1&name=8.1)

### PHP-CLI

- [![`shinsenter/php:${PHP_VERSION}-cli`](https://img.shields.io/docker/image-size/shinsenter/php/cli?label=shinsenter%2Fphp%3Acli)](https://docker.shin.company/php/tags?page=1&name=cli)

### PHP-FPM
- [![`shinsenter/php:${PHP_VERSION}-fpm`](https://img.shields.io/docker/image-size/shinsenter/php/fpm?label=shinsenter%2Fphp%3Afpm)](https://docker.shin.company/php/tags?page=1&name=fpm)

### PHP-FPM + Apache
- [![`shinsenter/phpfpm-apache`](https://img.shields.io/docker/image-size/shinsenter/phpfpm-apache/latest?label=shinsenter%2Fphpfpm-apache)](https://docker.shin.company/phpfpm-apache)

### PHP-FPM + Nginx
- [![`shinsenter/phpfpm-nginx`](https://img.shields.io/docker/image-size/shinsenter/phpfpm-nginx/latest?label=shinsenter%2Fphpfpm-nginx)](https://docker.shin.company/phpfpm-nginx)

### Popular PHP open source projects

I also added more popular PHP open source projects:

- [![`shinsenter/cakephp4`](https://img.shields.io/docker/image-size/shinsenter/cakephp4/latest?label=shinsenter%2Fcakephp4)](https://docker.shin.company/cakephp4)
- [![`shinsenter/codeigniter4`](https://img.shields.io/docker/image-size/shinsenter/codeigniter4/latest?label=shinsenter%2Fcodeigniter4)](https://docker.shin.company/codeigniter4)
- [![`shinsenter/crater`](https://img.shields.io/docker/image-size/shinsenter/crater/latest?label=shinsenter%2Fcrater)](https://docker.shin.company/crater)
- [![`shinsenter/flarum`](https://img.shields.io/docker/image-size/shinsenter/flarum/latest?label=shinsenter%2Fflarum)](https://docker.shin.company/flarum)
- [![`shinsenter/fuelphp`](https://img.shields.io/docker/image-size/shinsenter/fuelphp/latest?label=shinsenter%2Ffuelphp)](https://docker.shin.company/fuelphp)
- [![`shinsenter/grav`](https://img.shields.io/docker/image-size/shinsenter/grav/latest?label=shinsenter%2Fgrav)](https://docker.shin.company/grav)
- [![`shinsenter/hyperf`](https://img.shields.io/docker/image-size/shinsenter/hyperf/latest?label=shinsenter%2Fhyperf)](https://docker.shin.company/hyperf)
- [![`shinsenter/kirby`](https://img.shields.io/docker/image-size/shinsenter/kirby/latest?label=shinsenter%2Fkirby)](https://docker.shin.company/kirby)
- [![`shinsenter/laminas`](https://img.shields.io/docker/image-size/shinsenter/laminas/latest?label=shinsenter%2Flaminas)](https://docker.shin.company/laminas)
- [![`shinsenter/laravel`](https://img.shields.io/docker/image-size/shinsenter/laravel/latest?label=shinsenter%2Flaravel)](https://docker.shin.company/laravel)
- [![`shinsenter/phpmyadmin`](https://img.shields.io/docker/image-size/shinsenter/phpmyadmin/latest?label=shinsenter%2Fphpmyadmin)](https://docker.shin.company/phpmyadmin)
- [![`shinsenter/symfony`](https://img.shields.io/docker/image-size/shinsenter/symfony/latest?label=shinsenter%2Fsymfony)](https://docker.shin.company/symfony)
- [![`shinsenter/slim`](https://img.shields.io/docker/image-size/shinsenter/slim/latest?label=shinsenter%2Fslim)](https://docker.shin.company/slim)
- [![`shinsenter/statamic`](https://img.shields.io/docker/image-size/shinsenter/statamic/latest?label=shinsenter%2Fstatamic)](https://docker.shin.company/statamic)
- [![`shinsenter/wordpress`](https://img.shields.io/docker/image-size/shinsenter/wordpress/latest?label=shinsenter%2Fwordpress)](https://docker.shin.company/wordpress)
- [![`shinsenter/yii`](https://img.shields.io/docker/image-size/shinsenter/yii/latest?label=shinsenter%2Fyii)](https://docker.shin.company/yii)

## Pre-installed PHP modules

The following PHP extensions are pre-installed in every docker image.

```
apcu            json            shmop         zip
bcmath          libxml          simple_xml    zlib
calendar        mbstring        simplexml
core            memcached       soap
ctype           msgpack         sockets
curl            mysqli          sodium
date            mysqlnd         spl
dom             opcache         sqlite3
exif            openssl         standard
ffi             pcntl           sysvmsg
fileinfo        pcre            sysvsem
filter          pdo             sysvshm
ftp             pdo_mysql       tidy
gd              pdo_sqlite      tokenizer
gettext         phar            uuid
gmp             posix           xml
hash            readline        xmlreader
iconv           redis           xmlwriter
igbinary        reflection      xsl
intl            session         yaml
```

You can also easily [add more PHP modules](#enabling-or-disabling-php-modules) or [install Ubuntu packages](#installing-linux-packages) by [customizing your Docker image](#customize-docker-image).

## Usage

### Docker Pull command

```bash
docker pull shinsenter/php:${PHP_VERSION}-${PHP_VARIATION}
```

> View more image tags at [shinsenter/php/tags](https://docker.shin.company/php/tags).

### The document root

You can choose your own path for the document root by using the environment variable `$WEBHOME`.

```Dockerfile
ENV WEBHOME="/var/www/html"
```

> The default document root is set to `/var/www/html`, and your application must be copied or mounted to this path.

> Sometimes you may wish to change the default document root (away from `/var/www/html`), please consider changing the `$WEBHOME` value.

### Composer

The latest version of Composer is installed and ready to use.

> Composer is a tool for dependency management in PHP, written in PHP. It allows you to declare the libraries your project depends on and it will manage (install/update) them for you. You can read more about Composer in our [official documentation](https://getcomposer.org/doc).

### Access to your container

Just open a terminal and run below command to access to your container:

```bash
docker exec -it <container_id> /bin/bash
```

### Enabling or disabling PHP modules

There are many [pre-installed PHP modules](#pre-installed-php-modules) in the `shinsenter/php` Docker images, and I think it is quite enough for different PHP projects. If you want to add/remove these modules here is the guide.

The `shinsenter/php` Docker images provide some helper scripts to more easily install/remove or enable/disable PHP extensions.
- `phpaddmod` (or `docker-php-ext-install`)
- `phpdelmod` (or `docker-php-ext-remove`)
- `phpenmod` (or `docker-php-ext-enable`)
- `phpdismod` (or `docker-php-ext-disable`)

#### Installing PHP modules:

```bash
docker exec -it <container_id> phpaddmod <module names, space-delimited list>
```

E.g.: `docker exec -it my-container phpaddmod imagick pgsql solr`

#### Removing PHP modules:

```bash
docker exec -it <container_id> phpdelmod <module names, space-delimited list>
```

E.g.: `docker exec -it my-container phpdelmod imagick pgsql solr`

### Composer command

Running a Composer command:

```bash
docker exec -it <container_id> composer <arguments>
```

E.g.: `docker exec -it my-container composer install`

### Installing linux packages

Access to your container by running `bash` inside the container:

```bash
docker exec -it <container_id> /bin/bash
```

Run following Ubuntu's `apt` commands to install packages and any dependency needed.

```bash
apt-get update -y
apt-get install -y <package_name>
```

### Docker Run command

```bash
docker run --rm [run options] shinsenter/php:${PHP_VERSION}-${PHP_VARIATION} <your_command>
```

For example:

```bash
docker run --rm -v $(pwd):/var/www/html -e PUID=$(id -u) -e PGID=$(id -g) shinsenter/php:8.1-cli composer create-project laravel/laravel my-app
```

## Customize Docker image

Here below is a sample `Dockerfile` for building your own Docker image extending one of above images. You also can change below pre-defined Docker's ENV lines to change PHP-FPM behavior without copying configuration files to your containers.

> Learn more about [Dockerfile](https://docs.docker.com/engine/reference/builder).

```Dockerfile
# change the PHP_VERSION and PHP_VARIATION as your need
ARG PHP_VERSION=8.1
ARG PHP_VARIATION=fpm-nginx

# extends from base image
FROM shinsenter/php:${PHP_VERSION}-${PHP_VARIATION}

# ==========================================================

# you may want to install some PHP modules
# e.g: the following line will install imagick, pgsql, solr modules
RUN phpaddmod imagick pgsql solr

# ==========================================================

# Control your timezone
ENV TZ="UTC"

# sets GID and UID
ENV PUID=9999
ENV PGID=9999

# sets web server root path
ENV WEBHOME="/var/www/html"

# set ENABLE_CRONTAB=true to enable crontab
ENV ENABLE_CRONTAB=false

# ==========================================================

# Server that should relay emails for MSMTP
ENV MSMTP_RELAY_SERVER_HOSTNAME="mailhog"

# Port the SMTP server is listening on
ENV MSMTP_RELAY_SERVER_PORT="1025"

# ==========================================================

# Default charset
ENV PHP_DEFAULT_CHARSET="UTF-8"

# Show PHP errors on screen
ENV PHP_DISPLAY_ERRORS="On"

# Set PHP error reporting level
ENV PHP_ERROR_REPORTING="E_ALL & ~E_DEPRECATED & ~E_STRICT & ~E_WARNING"

# Set the maximum time in seconds a script is allowed
# to run before it is terminated by the parser
ENV PHP_MAX_EXECUTION_TIME="99"

# Set the maximum amount of memory in bytes that a script is allowed to allocate
ENV PHP_MEMORY_LIMIT="256M"

# Limit the files that can be accessed by PHP to the specified directory-tree
# Default: PHP_OPEN_BASEDIR="$WEBHOME"
# Example: PHP_OPEN_BASEDIR="$WEBHOME:/data/uploads"
ENV PHP_OPEN_BASEDIR="$WEBHOME"

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
ENV PHP_OPCACHE_INTERNED_STRINGS_BUFFER="64"

# The maximum number of keys (and therefore scripts) in the OPcache hash table
ENV PHP_OPCACHE_MAX_ACCELERATED_FILES="130987"

# The maximum percentage of wasted memory that is allowed before a restart is scheduled
ENV PHP_OPCACHE_MAX_WASTED_PERCENTAGE="15"

# The size of the shared memory storage used by OPcache, in megabytes
ENV PHP_OPCACHE_MEMORY_CONSUMPTION="256"

# This directive facilitates to let the preloading to be run as another user
ENV PHP_OPCACHE_PRELOAD_USER="webuser"

# Specifies a PHP script that is going to be compiled and executed at start-up
ENV PHP_OPCACHE_PRELOAD=

# How often to check script timestamps for updates, in seconds
ENV PHP_OPCACHE_REVALIDATE_FREQ="5"

# If disabled, existing cached files using the same include_path will be reused
ENV PHP_OPCACHE_REVALIDATE_PATH="0"

# If disabled, all documentation comments will be discarded
# from the opcode cache to reduce the size of the optimised code
ENV PHP_OPCACHE_SAVE_COMMENTS="1"

# If enabled, OPcache will check for updated scripts
# every opcache.revalidate_freq seconds
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="1"
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
    image: shinsenter/php:${PHP_VERSION}-${PHP_VARIATION}
    volumes:
      - ./myapp:/var/www/html
    environment:
      TZ: UTC
      PUID: ${UID:-9999}
      PGID: ${GID:-9999}
    links:
      - mysql
      - redis

  ## OTHER CONTAINERS SUCH AS REDIS OR MYSQL ###################################
  mysql:
    image: mysql:latest
    environment:
      TZ: UTC
      MYSQL_ROOT_PASSWORD: mydb_p@ssw0rd
      MYSQL_DATABASE: my_database
    volumes:
      - "./mysql/data:/var/lib/mysql"
      - "./mysql/dump:/docker-entrypoint-initdb.d"
    ports:
      - "3306:3306"
  redis:
    image: redis:latest
    ports:
      - "6379:6379"
```

Then run below command to start containers.

```bash
docker-compose up -d
```

## Supported platforms

Currently, the supported architectures are:

- linux/amd64
- linux/arm/v7
- linux/arm64
- linux/ppc64le

> You do not need to use a platform-specific tag (although you can), Docker will automatically choose the appropriate architecture.
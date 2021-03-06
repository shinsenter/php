# shinsenter/phpfpm-apache

🌏 (PHP) Ubuntu + PHP-FPM + Apache2 Docker images with plenty of common and useful extensions.

> 🔗 https://docker.shin.company/phpfpm-apache

> 🚀 `shinsenter/phpfpm-apache` is also available in [smaller minified version](https://docker.shin.company/phpfpm-apache/tags?page=1&name=tidy).

> 📦 Built on top of [shinsenter/php](https://docker.shin.company/php) docker base image.

[![Docker Pulls](https://img.shields.io/docker/pulls/shinsenter/phpfpm-apache)](https://docker.shin.company/phpfpm-apache) [![Docker Image Size](https://img.shields.io/docker/image-size/shinsenter/phpfpm-apache/latest?label=shinsenter%2Fphpfpm-apache)](https://docker.shin.company/phpfpm-apache)

* * *

## About this project

🌏 (PHP) Production-ready Ubuntu + PHP-FPM + [Apache2](https://httpd.apache.org) Docker images with plenty of common and useful extensions for your PHP applications. These images are actively maintained.

You can also easily [add more PHP modules](#enabling-or-disabling-php-modules) or [customize your Docker image](#customize-docker-image).

> There are many guide about configuring Apache2 with PHP-FPM, but many of them are incomplete or contain security issues. More information can be found at their [official website](https://cwiki.apache.org/confluence/display/httpd/PHP-FPM).

> 💡 To ensure that the image size is always compact and suitable for many different existing projects, the source code of the framework is not included in the container. The download size is under 100MB.

## Usage

### Docker Pull command

```bash
docker pull shinsenter/phpfpm-apache:latest
```

or

```bash
docker pull shinsenter/phpfpm-apache:php${PHP_VERSION}
```

or

```bash
docker pull shinsenter/phpfpm-apache:php${PHP_VERSION}-tidy
```

> View more image tags at [shinsenter/phpfpm-apache/tags](https://docker.shin.company/phpfpm-apache/tags).

### The document root

You can choose your own path for the document root by using the environment variable `$WEBHOME`.

```Dockerfile
ENV WEBHOME="/var/www/html"
```

> The default document root is set to `/var/www/html`, and your application must be copied or mounted to this path.

> Sometimes you may wish to change the default document directory of Apache, for example if the `index.php` is placed in a `public` directory within the `$WEBHOME` path, you also can change it using an environment variable called `$APACHE_DOCUMENT_ROOT`.

```Dockerfile
ENV APACHE_DOCUMENT_ROOT="/public"
```

### Composer

The latest version of Composer is installed and ready to use.

> Composer is a tool for dependency management in PHP, written in PHP. It allows you to declare the libraries your project depends on and it will manage (install/update) them for you. You can read more about Composer in our [official documentation](https://getcomposer.org/doc).

### Access to your container

Just open a terminal and run below command to access to your container:

```bash
docker exec -it <container_id> /bin/bash
```

### Enabling or disabling PHP modules

There are many [pre-installed PHP modules](https://code.shin.company/php#pre-installed-php-modules) in the `shinsenter/php` Docker images, and I think it is quite enough for different PHP projects. If you want to add/remove these modules here is the guide.

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

### Docker Run command

```bash
docker run --rm [run options] shinsenter/phpfpm-apache <your_command>
```

For example:

```bash
docker run --rm -v $(pwd):/var/www/html -e PUID=$(id -u) -e PGID=$(id -g) shinsenter/phpfpm-apache composer dump-autoload
```

## Customize Docker image

Here below is a sample `Dockerfile` for building your own Docker image extending this image. You also can add more [pre-defined Docker's ENV settings](https://code.shin.company/php#customize-docker-image) to change PHP-FPM behavior without copying configuration files to your containers.

> Learn more about [Dockerfile](https://docs.docker.com/engine/reference/builder).

```Dockerfile
ARG  PHP_VERSION=8.1
FROM shinsenter/phpfpm-apache:php${PHP_VERSION}

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

# Sets the directory from which Apache will serve files
ENV WEBHOME="/var/www/html"

# Set Apache root folder within $WEBHOME
# E.g: APACHE_DOCUMENT_ROOT="/public"
ENV APACHE_DOCUMENT_ROOT=""

# Set to "true" to fix permission for whole $WEBHOME
ENV FIX_WEBHOME_PERMISSION="false"

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

# You can easily change PHP-FPM configurations
# by using pre-defined Docker's environment variables.
# Learn more: https://code.shin.company/php#customize-docker-image
```

Then run below command to build your Docker image.

```bash
docker build [build options] - < Dockerfile
```

## Docker Compose example

Create an empty directory for a new project and place in the directory a `docker-compose.yml` file with below content.

> Learn more about [Docker Compose](https://docs.docker.com/compose).

> To configure an HTTPS server, you need to mount the directory of the server certificate `server.crt` and private key `server.key` files to container's `/etc/ssl/web` path. You can also use a modern HTTP reverse proxy like [Traefik](https://hub.docker.com/_/traefik).

```yml
version: '3'
services:
  my-container:
    image: shinsenter/phpfpm-apache:latest
    volumes:
      - ./my-website:/var/www/html
      - ./ssl-certs:/etc/ssl/web
    environment:
      TZ: UTC
      PUID: ${UID:-9999}
      PGID: ${GID:-9999}
    ports:
      - "80:80"
      - "443:443"
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
- linux/arm64/v8
- linux/ppc64le

> You do not need to use a platform-specific tag (although you can), Docker will automatically choose the appropriate architecture.
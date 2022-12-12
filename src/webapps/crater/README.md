# shinsenter/crater

🔰 (PHP) Run Crater on Docker (for both production and local development).

> 🔗 https://docker.shin.company/crater

> 🚀 `shinsenter/crater` is also available in [smaller minified version](https://docker.shin.company/crater/tags?page=1&name=tidy).

> 📦 Built on top of [shinsenter/php](https://docker.shin.company/php) docker base image.

[![Docker Pulls](https://img.shields.io/docker/pulls/shinsenter/crater)](https://docker.shin.company/crater) [![Docker Image Size](https://img.shields.io/docker/image-size/shinsenter/crater/latest?label=shinsenter%2Fcrater)](https://docker.shin.company/crater)

* * *

## About this project

🔰 (PHP) Run Crater on Docker easily with a single Docker container.

These images are built on top of latest LTS versions of Ubuntu + PHP-FPM and actively maintained.

You can also easily [add more PHP modules](#enabling-or-disabling-php-modules) or [customize your Docker image](#customize-docker-image).

> Crater is an open-source web & mobile app that helps you track expenses, payments & create professional invoices & estimates. More information can be found at their [official website](https://docs.craterapp.com).

> 💡 To ensure that the image size is always compact and suitable for many different existing projects, the source code of the framework is not included in the container. The download size is under 100MB.

> ⏬ When you start a container mounting an empty directory to the document root path (the default document root is set to `/var/www/html`), the container will automatically pull the latest source code of the framework.


## Usage

### Docker Pull command

```bash
docker pull shinsenter/crater:latest
```

or

```bash
docker pull shinsenter/crater:php${PHP_VERSION}
```

or

```bash
docker pull shinsenter/crater:php${PHP_VERSION}-tidy
```

> View more image tags at [shinsenter/crater/tags](https://docker.shin.company/crater/tags).

### The document root

You can choose your own path for the document root by using the environment variable `$WEBHOME`.

```Dockerfile
ENV WEBHOME="/var/www/html"
```

> The default document root is set to `/var/www/html`, and your application must be copied or mounted to this path.

> Sometimes you may wish to change the default document root (away from `/var/www/html`), please consider changing the `$WEBHOME` value.

After changing the `$WEBHOME` variable, you also have to change your default working directory by adding these lines to the bottom of your `Dockerfile`:

```
# sets the working directory
WORKDIR $WEBHOME
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
docker run --rm [run options] shinsenter/crater <your_command>
```

For example:

```bash
docker run --rm -v $(pwd):/var/www/html -e PUID=$(id -u) -e PGID=$(id -g) shinsenter/crater composer dump-autoload
```

## Customize Docker image

Here below is a sample `Dockerfile` for building your own Docker image extending this image. You also can add more [pre-defined Docker's ENV settings](https://code.shin.company/php#customize-docker-image) to change PHP-FPM behavior without copying configuration files to your containers.

> Learn more about [Dockerfile](https://docs.docker.com/engine/reference/builder).

```Dockerfile
ARG  PHP_VERSION=8.2
FROM shinsenter/crater:php${PHP_VERSION}

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

# ==========================================================

# Optimize and cache all config, views, routes
ENV CRATER_AUTO_OPTIMIZE=true

# Create symlinks to the storage folder
ENV CRATER_LINK_STORAGE=true

# Run Crater migrations (for development purposese)
ENV CRATER_AUTO_MIGRATION=false

# Auto start artisan queue:work when container is up
ENV CRATER_QUEUE_ENABLED=false

# Extra arguments for artisan queue:work
# Example: ENV CRATER_QUEUE_OPTIONS="--timeout=10 --tries=3 redis"
ENV CRATER_QUEUE_OPTIONS=

# Auto start artisan schedule:work when container is up
ENV CRATER_SCHEDULE_ENABLED=true

# Extra arguments for artisan schedule:work
ENV CRATER_SCHEDULE_OPTIONS=

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
    image: shinsenter/crater:latest
    volumes:
      - ./my-website:/var/www/html
      - ./ssl-certs:/etc/ssl/web
    environment:
      TZ: UTC
      PUID: ${UID:-9999}
      PGID: ${GID:-9999}
      REDIS_HOST: redis
      DB_HOST: mysql
      DB_DATABASE: crater
      DB_USERNAME: root
      DB_PASSWORD: mydb_p@ssw0rd
      # CRATER_QUEUE_ENABLED: true
      # CRATER_QUEUE_OPTIONS: --timeout=60 --tries=3 redis
      # CRATER_SCHEDULE_ENABLED: true
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
      MYSQL_DATABASE: crater
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
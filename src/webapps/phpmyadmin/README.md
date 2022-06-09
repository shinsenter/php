# shinsenter/phpmyadmin

🔰 (PHP) phpMyAdmin Docker images for development and production.

> 🔗 https://docker.shin.company/phpmyadmin

> 🚀 `shinsenter/phpmyadmin` is also available in [smaller minified version](https://docker.shin.company/phpmyadmin/tags?page=1&name=tidy).

> 📦 Built on top of [shinsenter/php](https://docker.shin.company/php) docker base image.

[![Docker Pulls](https://img.shields.io/docker/pulls/shinsenter/phpmyadmin)](https://docker.shin.company/phpmyadmin) [![Docker Image Size](https://img.shields.io/docker/image-size/shinsenter/phpmyadmin/latest?label=shinsenter%2Fphpmyadmin)](https://docker.shin.company/phpmyadmin)

* * *

## About this project

🔰 (PHP) phpMyAdmin Docker images for development and production. These images are actively maintained.

The World's smallest Ubuntu-based Docker image for phpMyAdmin.

You can also easily [add more PHP modules](#enabling-or-disabling-php-modules) or [customize your Docker image](#customize-docker-image).

> phpMyAdmin is intended to handle the administration of MySQL over the web. More information can be found at their [official website](https://www.phpmyadmin.net).

> 💡 To ensure that the image size is always compact and suitable for many different existing projects, the source code of the framework is not included in the container.

> ⏬ However, if you want to start a new project, mount an empty directory to the document root path, it will automatically pull the latest version of the framework when you start the container.

## Usage

### Docker Pull command

```bash
docker pull shinsenter/phpmyadmin:latest
```

or

```bash
docker pull shinsenter/phpmyadmin:php${PHP_VERSION}
```

or

```bash
docker pull shinsenter/phpmyadmin:php${PHP_VERSION}-tidy
```

> View more image tags at [shinsenter/phpmyadmin/tags](https://docker.shin.company/phpmyadmin/tags).

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
docker run --rm [run options] shinsenter/phpmyadmin <your_command>
```

For example:

```bash
docker run --rm -v $(pwd):/var/www/html -e PUID=$(id -u) -e PGID=$(id -g) shinsenter/phpmyadmin composer dump-autoload
```

## Customize Docker image

Here below is a sample `Dockerfile` for building your own Docker image extending this image. You also can add more [pre-defined Docker's ENV settings](https://code.shin.company/php#customize-docker-image) to change PHP-FPM behavior without copying configuration files to your containers.

> Learn more about [Dockerfile](https://docs.docker.com/engine/reference/builder).

```Dockerfile
ARG  PHP_VERSION=8.0
FROM shinsenter/phpmyadmin:php${PHP_VERSION}

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

ENV PMA_HOST=mysql
# ENV PMA_USER=
# ENV PMA_PASSWORD=
# ENV PMA_PORT=
# ENV PMA_PMADB=
# ENV PMA_SOCKET=
# ENV PMA_VERBOSE=

# ENV PMA_ABSOLUTE_URI=
# ENV PMA_ARBITRARY=
# ENV PMA_BLOWFISH_SECRET=
# ENV PMA_CONTROLHOST=
# ENV PMA_CONTROLPASS=
# ENV PMA_CONTROLPORT=
# ENV PMA_CONTROLUSER=
# ENV PMA_DEFAULTLANG=
# ENV PMA_HOSTS=
# ENV PMA_PORTS=
# ENV PMA_SOCKETS=
# ENV PMA_VERBOSES=
# ENV PMA_MAXROWS=
# ENV PMA_PROPERTIESNUMCOLUMNS=
# ENV PMA_PROTECTBINARY=
# ENV PMA_QUERYHISTORYDB=
# ENV PMA_QUERYHISTORYMAX=
# ENV PMA_ROWACTIONTYPE=
# ENV PMA_SENDERRORREPORTS=
# ENV PMA_SHOWALL=
# ENV PMA_URLQUERYENCRYPTION=
# ENV PMA_URLQUERYENCRYPTIONSECRETKEY=

# ==========================================================

# recommended settings
ENV PHP_MAX_EXECUTION_TIME=600
ENV PHP_MEMORY_LIMIT=512M
ENV PHP_POST_MAX_SIZE=2G
ENV PHP_UPLOAD_MAX_FILE_SIZE=2G

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
    image: shinsenter/phpmyadmin:latest
    volumes:
      - ./my-website:/var/www/html
      - ./ssl-certs:/etc/ssl/web
    environment:
      TZ: UTC
      PUID: ${UID:-9999}
      PGID: ${GID:-9999}
      PMA_HOST: mysql
      PMA_USER: root
      PMA_PASSWORD: mydb_p@ssw0rd
    ports:
      - "80:80"
      - "443:443"
    links:
      - mysql

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
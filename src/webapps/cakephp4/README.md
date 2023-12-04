# shinsenter/cakephp4

🔰 (PHP) Run CakePHP on Docker (for both production and local development).

> 🔗 https://docker.shin.company/cakephp4

> 🚀 `shinsenter/cakephp4` is also available in [smaller minified version](https://docker.shin.company/cakephp4/tags?page=1&name=tidy).

> 📦 Built on top of [shinsenter/php](https://docker.shin.company/php) docker base image.

[![Docker Pulls](https://img.shields.io/docker/pulls/shinsenter/cakephp4)](https://docker.shin.company/cakephp4) [![Docker Image Size](https://img.shields.io/docker/image-size/shinsenter/cakephp4/latest?label=shinsenter%2Fcakephp4)](https://docker.shin.company/cakephp4)

* * *

## About this project

🔰 (PHP) Run CakePHP on Docker easily with a single Docker container.

> CakePHP is a rapid development framework for PHP which uses commonly known design patterns like Associative Data Mapping, Front Controller, and MVC. More information can be found at their [official website](https://cakephp.org).

Stay ahead of the curve with our actively maintained and updated images, built on the solid foundation of the latest LTS versions of Ubuntu and PHP-FPM for maximum stability and performance.

> With these Docker images, you can easily [add more PHP modules](#enabling-or-disabling-php-modules) or [customize your Docker image](#customize-docker-image) to fit your specific needs.

> 💡 Streamline your project workflow and save storage space with our compact and versatile Docker images, boasting a lightweight download size of under 100MB without sacrificing on functionality.

> ⏬ Docker container will automatically pull the latest source code of the framework upon startup, when you mount an empty directory to the document root path (which is set to `/var/www/html` by default).

## Usage

### Docker Pull command

```bash
docker pull shinsenter/cakephp4:latest
```

or

```bash
docker pull shinsenter/cakephp4:php${PHP_VERSION}
```

or

```bash
docker pull shinsenter/cakephp4:php${PHP_VERSION}-tidy
```

> View more image tags at [shinsenter/cakephp4/tags](https://docker.shin.company/cakephp4/tags).

### The document root

By default, your application will be placed in the `/var/www/html` directory of the Docker container, also known as the document root. However, if you want to change the location of your application, you can simply adjust the `WEBHOME` environment variable.

```Dockerfile
ENV WEBHOME="/var/www/html"
```

But don't forget, after changing this variable, you'll also need to update your default working directory in the Dockerfile. No worries, it's easy to do! Just add a couple of lines to the bottom of your Dockerfile and you're good to go:

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
docker run --rm [run options] shinsenter/cakephp4 <your_command>
```

For example:

```bash
docker run --rm -v $(pwd):/var/www/html -e PUID=$(id -u) -e PGID=$(id -g) shinsenter/cakephp4 composer dump-autoload
```

## Customize Your Docker Image

Easily change container configurations and tailor your image to your specific needs by utilizing pre-defined Docker environment variables.

Look no further than this `Dockerfile` sample for building your own custom image by extending the base image provided here.

> Want to learn more about how to create the ultimate custom image? Check out the [Dockerfile documentation](https://docs.docker.com/engine/reference/builder) and start building today.

But that's not all - you can also add more [pre-defined Docker environment variables](https://code.shin.company/php#customize-docker-image) to change PHP-FPM behavior without copying configuration files to your containers.

```Dockerfile
ARG  PHP_VERSION=8.3
FROM shinsenter/cakephp4:php${PHP_VERSION}

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
  cakephp4-app:
    image: shinsenter/cakephp4:latest
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
      - db
      - redis

  ## OTHER CONTAINERS SUCH AS REDIS OR DATABASE ###################################
  db:
    image: mariadb:latest
    environment:
      TZ: UTC
      MYSQL_ROOT_PASSWORD: mydb_p@ssw0rd
      MYSQL_DATABASE: my_database
    volumes:
      - "./db/data:/var/lib/mysql"
      - "./db/dump:/docker-entrypoint-initdb.d"
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
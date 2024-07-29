# PHP Docker Images

📦 Simplified PHP Docker images for effortless customization and extension setup.

- Docker Hub: https://hub.docker.com/r/shinsenter/php
- GitHub Packages: https://github.com/shinsenter/php/pkgs/container/php

[![shinsenter/php](https://repository-images.githubusercontent.com/458053748/24e848e1-c0fc-4893-b2b9-f7dbfad263f3)](https://docker.shin.company/php)

## Introduction

Our PHP Docker images are based on the [official PHP Docker images](https://hub.docker.com/_/php).
These images facilitate the easy adjustment of PHP and PHP-FPM settings using environment variables,
eliminating the need to rebuild images when making configuration changes.

These images also come with the latest version of [Composer](https://getcomposer.org)
and popular web servers like [Apache2](https://httpd.apache.org), [Nginx](https://nginx.org), [RoadRunner](https://roadrunner.dev), [FrankenPHP](https://frankenphp.dev) or [Nginx Unit](https://unit.nginx.org).
This setup allows for faster project initiation without additional installations.

> 🪶 Info: While built on the official PHP images and including more useful extensions,
> we have **significantly reduced the image sizes** compared to the base images.
> This optimization improves download times and resource usage without sacrificing functionality,
> thanks to the [docker-squash](https://code.shin.company/docker-squash) project.

## Image Variants

Our image tags cover PHP versions from 5.6 to 8.4<sup>(*)</sup>,
available in `cli`, `fpm`, `fpm-nginx`, `fpm-apache`, `roadrunner`<sup>(1)</sup>, `frankenphp`<sup>(2)</sup>, and `unit-php`<sup>(3)</sup> variants.

Examples include:
- `shinsenter/php:7.3-cli`
- `shinsenter/php:7.4-fpm`
- `shinsenter/php:8.0-fpm-apache`
- `shinsenter/php:8.1-fpm-nginx`
- `shinsenter/php:8.2-roadrunner` <sup>(1)</sup>
- `shinsenter/php:8.3-frankenphp` <sup>(2)</sup>
- `shinsenter/php:8.4-unit-php` <sup>(3)</sup>

> <sup>(*)</sup>: The latest stable version is 8.3.<br>
> <sup>(1)</sup>: PHP with RoadRunner server. The `roadrunner` variant supports PHP >= 8.0.<br>
> <sup>(2)</sup>: FrankenPHP is still in BETA. The `frankenphp` variant supports PHP >= 8.2.<br>
> <sup>(3)</sup>: PHP with Nginx Unit server. The `unit-php` variant supports PHP >= 7.4.

Explore all available tags on our [Docker Hub](https://hub.docker.com/r/shinsenter/php/tags).

For stable versions suitable for production, we also offer version tags on [another repository](https://hub.docker.com/r/shinsenter/php-archives/tags).

> 💡 Hint: Docker image tags ending in `-alpine` or `-tidy` indicate images built on the Alpine Linux base OS.
> These images are lightweight, speeding up builds and saving bandwidth for your CI/CD pipelines.

### Examples

You can easily run a container by copying and pasting one of these `docker run` commands:

#### CLI

```shell
# non-interactive
docker run --rm shinsenter/php:8.3-cli php -m

# interactive
docker run -it -v ./myproject:/var/www/html shinsenter/php:8.3-cli
```

#### PHP-FPM

```shell
docker run -v ./myproject:/var/www/html -p 9000:9000 shinsenter/php:8.3-fpm
```

#### PHP-FPM + Nginx (or Apache, RoadRunner, FrankenPHP, Nginx Unit)

```shell
# with Nginx
docker run -v ./myproject:/var/www/html -p 80:80 -p 443:443 shinsenter/php:8.3-fpm-nginx

# with Apache
docker run -v ./myproject:/var/www/html -p 80:80 -p 443:443 shinsenter/php:8.3-fpm-apache

# with RoadRunner
docker run -v ./myproject:/var/www/html -p 80:80 -p 443:443 shinsenter/php:8.3-roadrunner

# with FrankenPHP
docker run -v ./myproject:/var/www/html -p 80:80 -p 443:443 shinsenter/php:8.3-frankenphp

# with Nginx Unit
docker run -v ./myproject:/var/www/html -p 80:80 -p 443:443 shinsenter/php:8.3-unit-php
```

## Customizing Settings via Environment Variables

These images allow customizing PHP and PHP-FPM settings through environment variables instead of rebuilding images.

The environment variable names follow these conventions:
- Variables are prefixed with `PHP_` to avoid conflicts with other application variables.
- The rest of the variable name matches the configuration directive name from `php.ini` or `php-fpm.conf`:
    - PHP ini directives: https://www.php.net/manual/en/ini.list.php
    - PHP-FPM directives: https://www.php.net/manual/en/install.fpm.configuration.php
- Directive names are converted to `CONSTANT_CASE` - uppercase with underscores instead of dots or dashes.

This naming convention helps you easily identify which environment variable applies to which PHP/PHP-FPM configuration directive.

> 👉🏻 Info: By default, the `$PHP_*` environment variables only take effect when set before starting the container.
> To dynamically change PHP configurations using `$PHP_*` environment variables while running commands within the container,
> you need to start your container with the `ALLOW_RUNTIME_PHP_ENVVARS=1` environment variable.

> 💡 Hint: Run `php-envvars` in the container to get a full list of default `$PHP_*` environment variables.


### Examples

#### Command Line

```shell
docker run \
    -v ./myproject:/var/www/html \
    -e PHP_DISPLAY_ERRORS='1' \
    -e PHP_POST_MAX_SIZE='100M' \
    -e PHP_UPLOAD_MAX_FILESIZE='100M' \
    -e PHP_SESSION_COOKIE_HTTPONLY='1' \
    shinsenter/php:8.3 php -i
```

#### docker-compose.yml

```yaml
services:
  web:
    image: shinsenter/php:8.3-fpm-nginx
    environment:
      PHP_DISPLAY_ERRORS: "1"
      PHP_POST_MAX_SIZE: "100M"
      PHP_UPLOAD_MAX_FILESIZE: "100M"
      PHP_SESSION_COOKIE_HTTPONLY: "1"
```

#### Explanation

| Environment Variable          | Explanation                                        | Equivalent Configuration    |
|-------------------------------|----------------------------------------------------|-----------------------------|
| PHP_DISPLAY_ERRORS=1          | Enables displaying errors during development.      | `display_errors 1`          |
| PHP_POST_MAX_SIZE=100M        | Increases the maximum post size from the default 8MB.          | `post_max_size 100M`        |
| PHP_UPLOAD_MAX_FILESIZE=100M  | Increases the maximum upload file size from the default 2MB.   | `upload_max_filesize 100M`  |
| PHP_SESSION_COOKIE_HTTPONLY=1 | Enables the HttpOnly flag for session cookie security. | `session.cookie_httponly 1` |

> 💡 Hint: Run `php-envvars` in the container to get a full list of default `$PHP_*` environment variables.

## Pre-installed PHP Extensions

Popular PHP extensions are pre-installed by default, allowing projects to get started faster without additional installation.

```list
apcu
bcmath
calendar
exif
gd
gettext
igbinary
intl
msgpack
mysqli
opcache
pcntl
pdo_mysql
pdo_pgsql
redis
uuid
yaml
zip
```

> 👉🏻 Info: The pre-installed PHP extensions from the official Docker images are excluded from this list.

> 💡 Hint: Run `docker run --rm shinsenter/php:8.3-cli php -m` in the container
to get a list of extensions (you can replace `8.3` with a specific PHP version).

## Adding PHP Extensions

These images use a simple command called `phpaddmod` to install PHP extensions.

You don't need to run the more complex `docker-php-ext-install` command
or manually edit the `php.ini` file; `phpaddmod` handles the installation and configuration for you.

For example, in your `Dockerfile`:

```Dockerfile
FROM shinsenter/php:8.3-fpm-nginx

# Install imagick, swoole and xdebug
RUN phpaddmod imagick swoole xdebug

# Add your instructions here
# For example:
# ADD --chown=$APP_USER:$APP_GROUP ./myproject/ /var/www/html/
```

> 👉🏻 Info: The `phpaddmod` command is a wrapper around the [`mlocati/docker-php-extension-installer`](https://github.com/mlocati/docker-php-extension-installer) utility,
which takes care of all required steps to compile and activate the extensions.

> 💡 Hint: If you're having trouble figuring out which extensions can be installed,
have a look at [their documentation](https://github.com/mlocati/docker-php-extension-installer/blob/master/README.md#supported-php-extensions).

## Application Directory

The default application directory is `/var/www/html` and can be customized via the `$APP_PATH` environment variable:

```shell
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v "$PWD":/app \
    -e APP_PATH=/app \
    shinsenter/php:8.3-fpm-nginx
```

This changes the web application directory to `/app`.

Moreover, the default document root
(a relative path inside the application directory that contains your `index.php` file)
can be customized by setting the `$DOCUMENT_ROOT` environment variable:

```shell
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v "$PWD":/app \
    -e APP_PATH=/app \
    -e DOCUMENT_ROOT=/public \
    shinsenter/php:8.3-fpm-nginx
```

This would change the document root path to `/app/public`.

## Customizing Container User and Group in Docker

Override the default user and group settings by setting environment variables when running the container.

Available variables:

| Environment Variable | Description                             | Default          |
|----------------------|-----------------------------------------|------------------|
| `APP_USER`           | Username inside the container           | `www-data`       |
| `APP_GROUP`          | Group name inside the container         | `www-data`       |
| `APP_UID`            | Numeric UID of the user                 | UID in container |
| `APP_GID`            | Numeric GID of the group                | GID in container |

For example, to run a container as user `myapp` with UID `5000`:

```shell
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -e APP_USER=myapp \
    -e APP_UID=5000 \
    shinsenter/php:8.3-fpm-nginx
```

Or in a `docker-compose.yml`:
```yaml
services:
  web:
    image: shinsenter/php:8.3-fpm-nginx
    environment:
      - APP_USER=myapp
      - APP_UID=5000
```

## Autorun Scripts

Shell scripts placed in the `/startup/` directory will automatically run when the container starts, in alphabetical order by filename.
This feature can initialize projects before the main program runs, saving time by executing initialization scripts automatically.

#### Usage Example

Copy a script called `00-migration` into `/startup/` via a Dockerfile:

> Note: Ensure the script has executable permissions.

```Dockerfile
FROM shinsenter/php:8.3-cli

ADD ./autorun/00-migration /startup/00-migration
RUN chmod +x /startup/00-migration

# Add your instructions here
# For example:
# ADD --chown=$APP_USER:$APP_GROUP ./myproject/ /var/www/html/
```

> 👉🏻 Info: The startup directory already includes a script called `99-greeting` that prints a welcome message when the container starts.

```
      _    _                      _                _       _
 ___ | |_ |_| ___  ___  ___  ___ | |_  ___  ___   / | ___ | |_  ___
|_ -||   || ||   ||_ -|| -_||   ||  _|| -_||  _| / / | . ||   || . |
|___||_|_||_||_|_||___||___||_|_||_|  |___||_|  |_/  |  _||_|_||  _|
                                                     |_|       |_|

If you find my Docker images useful, consider donating via PayPal:
 -> https://www.paypal.me/shinsenter

(To edit this welcome message, add your text to /etc/welcome.txt)

---------------
Container     : shinsenter/php (built: 2024-08-01T00:00:00+0000)
Distro        : Debian GNU/Linux 12 (bookworm)
Timezone      : UTC (GMT+0000)
UID / GID     : www-data:www-data (33:33)
App Root      : /var/www/html
Document Root : /var/www/html
---------------

Docker Images by SHIN Company
Copyright (C) 2024 SHIN Company <shin@shin.company>

This software is free under the GNU General Public License (GPL).
You can redistribute and/or modify it under the terms of the GNU GPL.
This program is provided with the hope that it will be useful,
but it comes WITHOUT ANY WARRANTY. For more details, refer to the GNU GPL.

To get support, please contact: SHIN Company <shin@shin.company>
Docker Hub:      https://hub.docker.com/u/shinsenter
GitHub Packages: https://github.com/shinsenter?tab=packages

PHP 8.3.9 (cli) (built: Jul 23 2024 06:02:10) (NTS)
Copyright (c) The PHP Group
Zend Engine v4.3.9, Copyright (c) Zend Technologies
    with Zend OPcache v8.3.9, Copyright (c), by Zend Technologies
Composer version 2.7.7 2024-06-10 22:11:12
```

#### Disable Autorun Scripts

To disable autorun scripts, set `DISABLE_AUTORUN_SCRIPTS=1` as an environment variable.

For example, with `docker run`:

```shell
docker run -e DISABLE_AUTORUN_SCRIPTS=1 shinsenter/ubuntu-s6:latest bash
```

Or in `docker-compose.yml`:

```yaml
services:
  web:
    image: shinsenter/ubuntu-s6:latest
    environment:
      - DISABLE_AUTORUN_SCRIPTS=1
```

## Debug Mode

Enable "debug mode" for more verbose logging by setting `DEBUG=1` as an environment variable.
This can be used both with `docker run` and in `docker-compose.yml`.

#### Command Line

```shell
docker run -e DEBUG=1 shinsenter/php:8.3-fpm-nginx
```

#### docker-compose.yml

```yml
services:
  web:
    image: shinsenter/php:8.3-fpm-nginx
    environment:
      - DEBUG=1
```

## Other System Settings

These Docker images include additional environment variables for fine-tuning container behavior:

| Setting Name                       | Default Value    | Description                                                                                                                           | Example |
|------------------------------------|------------------|---------------------------------------------------------------------------------------------------------------------------------------|---------|
| `DEFAULT_LOG_PATH`                 | `/dev/stderr`    | Sets the log output path. By default, logs will be sent to the container's standard output.                                           | `/var/log/container.txt` |
| `DEBUG` or `DEBUG_MODE`            | Not set          | Activates debug mode with more verbose logs when set to `1`.                                                                          | 1 |
| `TZ`                               | `UTC`            | Sets the default timezone for the container. [Full list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).               | `Asia/Tokyo` |
| `ALLOW_RUNTIME_PHP_ENVVARS`        | Not set          | Enables the use of `$PHP_*` environment variables to dynamically change configurations when running PHP commands in the container.    | 1 |
| `INITIAL_PROJECT`                  | Not set          | Specifies a project for Composer to create in the app directory when it is empty.                                                     | `laravel/laravel` |
| `DISABLE_AUTORUN_CREATING_PROJECT` | Not set          | Prevents the creation of a new project when set to `1`. By default, Composer creates a project if `$INITIAL_PROJECT` is set and the app directory is empty. | 0 |
| `DISABLE_AUTORUN_COMPOSER_INSTALL` | Not set          | Disables `composer install` at startup when set to `1`. By default, `composer install` runs at startup if `composer.json` is present but packages are missing. | 0 |
| `DISABLE_AUTORUN_GENERATING_INDEX` | Not set          | Prevents the creation of `index.php` when set to `1`. By default, an `index.php` is created in the `$DOCUMENT_ROOT` directory if it doesn't exist. | 0 |
| `DISABLE_AUTORUN_SCRIPTS`          | Not set          | Disables all autorun scripts when set to `1`.                                                                                         | 0 |
| `ENABLE_CRONTAB`                   | Not set          | Enables the Crontab service when set to `1`, loading settings from the directory defined by `$CRONTAB_DIR` (default is `/etc/crontab.d`). | 1 |
| `CRONTAB_DIR`                      | `/etc/crontab.d` | Specifies the directory containing cron job settings. Cron jobs are run as the user defined by `$APP_USER`.                           | `/path/for/crontab/schedules` |
| `CRONTAB_HOME`                     | `$APP_PATH`      | Specifies the `$HOME` directory for cron jobs.                                                                                        | `/path/for/crontab` |
| `CRONTAB_MAILTO`                   | Not set          | Email address to which cron job logs are sent.                                                                                        | `admin@example.com` |
| `CRONTAB_PATH`                     | `$PATH`          | Sets the directory paths for executing cron jobs.                                                                                     | `/path/for/crontab/bin` |
| `CRONTAB_SHELL`                    | `/bin/sh`        | Sets the default shell for cron jobs.                                                                                                 | `/bin/bash` |
| `CRONTAB_TZ`                       | `$TZ`            | Sets the default timezone for cron jobs. [Full list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).                   | `Asia/Tokyo` |
| `ENABLE_TUNING_FPM`                | Not enabled      | Enables auto-tuning of PM control settings when set to `1`.                                                                           | 0 |
| `ENABLE_TUNING_MPM`                | Not enabled      | Enables auto-tuning of Apache MPM settings when set to `1`.                                                                           | 0 |
| `FIX_APP_PATH_PERMISSION`          | Not set          | Corrects ownership of the app directory when set to `1`.                                                                              | 1 |
| `DISABLE_GREETING`                 | Not set          | Disables the welcome message at container startup when set to `1`.                                                                    | 0 |

## Supported Platforms

Check our [Docker Hub](https://hub.docker.com/r/shinsenter/php/tags) for all available platforms.

> 💡 Hint: Docker image tags ending in `-alpine` or `-tidy` indicate images built on the Alpine Linux base OS.
> These images are lightweight, speeding up builds and saving bandwidth for your CI/CD pipelines.

## Stable Image Tags

We build new Docker images daily to ensure they stay up-to-date
with the latest upstream updates for PHP, base OS, Composer, etc.
The images in this repo are regularly updated under the same tag names.

For stable versions you can depend on in production,
we also apply version tags on another repository.

> 👉🏻 View Stable Tags: https://hub.docker.com/r/shinsenter/php-archives/tags

This way, you get frequently updated images under static tags,
providing both the latest code and production stability.

## Contributing

If you find these images useful, consider donating via [PayPal](https://www.paypal.me/shinsenter)
or opening an issue on [GitHub](https://github.com/shinsenter/php/issues/new).

Your support helps maintain and improve these images for the community.

## License

This project is licensed under the terms of the [GNU General Public License v3.0](https://code.shin.company/php/blob/main/LICENSE).

Please respect the intellectual efforts involved in creating these images.
If you intend to copy or use ideas from this project, proper credit is appreciated.

---

From Vietnam 🇻🇳 with love.

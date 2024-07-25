# PHP Docker Images

📦 Simplified PHP Docker images for effortless customization and extension setup.

> Docker Hub: https://hub.docker.com/r/shinsenter/php

[![shinsenter/php](https://repository-images.githubusercontent.com/458053748/24e848e1-c0fc-4893-b2b9-f7dbfad263f3)](https://docker.shin.company/php)

## Introduction

Our PHP Docker images are built on top of [the official PHP Docker images](https://hub.docker.com/_/php).
These images allow easy tweaking of PHP and PHP-FPM settings through environment variables,
eliminating the need to rebuild images when changing settings.

These images also include the latest version of [Composer](https://getcomposer.org),
along with well-known web servers like [Apache2](https://httpd.apache.org), [Nginx](https://nginx.org),
[Nginx Unit](https://unit.nginx.org), or [FrankenPHP](https://frankenphp.dev),
enabling projects to get started faster without additional installation.

> 🪶 Note: Although built on top of the official PHP images and including more useful extensions,
we have **drastically reduced the image sizes** compared to the base images while maintaining compatibility.
This optimization improves download times and resource usage without sacrificing functionality,
thanks to the [docker-squash](https://code.shin.company/docker-squash) project.

## Image Variants

The image tags cover PHP versions from 5.6 to 8.4<sup>(*)</sup>, available in `cli`, `fpm`, `fpm-nginx`, `fpm-apache`,
`frankenphp`<sup>(1)</sup>, and `unit-php`<sup>(2)</sup> variants.

> <sup>(*)</sup>: The latest stable version is 8.3.<br>
> <sup>(1)</sup>: FrankenPHP is still in BETA. The `frankenphp` variant supports PHP >= 8.2.<br>
> <sup>(2)</sup>: PHP with Nginx Unit. The `unit-php` variant supports PHP >= 7.4.

For example:
- `shinsenter/php:7.3-cli`
- `shinsenter/php:7.4-fpm`
- `shinsenter/php:8.0-fpm-apache`
- `shinsenter/php:8.1-fpm-nginx`
- `shinsenter/php:8.2-frankenphp` <sup>(1)</sup>
- `shinsenter/php:8.3-unit-php` <sup>(2)</sup>

Check our [Docker Hub](https://hub.docker.com/r/shinsenter/php/tags) for all available tags.

For stable versions you can depend on in production,
we also apply version tags on [another repository](https://hub.docker.com/r/shinsenter/php-archives/tags).

> 💡 Hint: Docker image tags ending in `-alpine` or `-tidy` indicate Docker images built on the Alpine Linux base operating system.
> These Docker images are lightweight, helping to speed up builds and save bandwidth for your CI/CD pipelines.

### Examples

You can simply copy and paste one of these `docker run` commands to run a container:

#### CLI

```shell
# non-interactive
docker run shinsenter/php:8.3-cli php -m

# interactive
docker run -it -v ./myproject:/var/www/html shinsenter/php:8.3-cli
```

#### PHP-FPM

```shell
docker run -v ./myproject:/var/www/html -p 9000:9000 shinsenter/php:8.3-fpm
```

#### PHP-FPM + Nginx (or Apache, FrankenPHP, Nginx Unit)

```shell
# with Nginx
docker run -v ./myproject:/var/www/html -p 80:80 -p 443:443 shinsenter/php:8.3-fpm-nginx

# with Apache
docker run -v ./myproject:/var/www/html -p 80:80 -p 443:443 shinsenter/php:8.3-fpm-apache

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

> 👉🏻 Info: By default, the `PHP_*` environment variables only take effect when set before starting the container.
> To dynamically change PHP configurations using `PHP_*` environment variables while running commands within the container,
> you need to start your container with the `ALLOW_RUNTIME_PHP_ENVVARS=1` environment variable.

> 💡 Hint: Run `php-envvars` in the container to get a full list of default `PHP_` environment variables.


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

> 💡 Hint: Run `env-default` or `env | sort | grep PHP_` in the container to get a full list of default environment values.

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

> 💡 Hint: Run `docker run shinsenter/php:8.3-cli php -m` in the container
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
```

> 👉🏻 Info: The `phpaddmod` command is a wrapper around the [`install-php-extensions`](https://github.com/mlocati/docker-php-extension-installer) utility,
which takes care of all required steps to compile and activate the extensions.

> 💡 Hint: If you're having trouble figuring out which extensions can be installed,
have a look at [the install-php-extensions project](https://github.com/mlocati/docker-php-extension-installer#supported-php-extensions).


## Application Directory

The default application directory is `/var/www/html` and can be customized via the `$APP_PATH` environment variable:

```shell
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v "$PWD":/app \
    -e APP_PATH=/app \
    shinsenter/php:8.3-fpm-nginx
```

This would change the web application directory to `/app`.

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


## Customize Container User and Group in Docker

The Docker image likely has a default user and group set,
such as `www-data` for a web server image. However, you can override these defaults
by setting environment variables when running the container.

The available variables are:

| Environment Variable | Description                             | Default          |
|----------------------|-----------------------------------------|------------------|
| `APP_USER`           | Sets the username inside the container  | `www-data`       |
| `APP_GROUP`          | Sets the groupname inside the container | `www-data`       |
| `APP_UID`            | Sets the numeric uid of the user        | uid in container |
| `APP_GID`            | Sets the numeric gid of the group       | gid in container |


For example, to run a container as the user `myapp` with uid `5000`, you could do:
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

Shell scripts copied into the `/startup/` directory of the container
will automatically run when the container starts, in alphabetical order by filename.

This mechanism can be used to initialize projects before the main program on the container runs.
The autorun feature saves time by executing initialization scripts without manual intervention.

> 💡 Note: Autorun scripts will run after the automatic installation script has finished.

#### Usage

For example, a script called `00-migration` could be copied into `/startup/` via a Dockerfile.

> Note: The script file must have executable permissions to run.

```Dockerfile
FROM shinsenter/php:8.3-cli

ADD ./autorun/00-migration /startup/00-migration
RUN chmod +x /startup/00-migration

# You may add your constructions from here
# For example:
# ADD --chown=$APP_USER:$APP_GROUP ./myproject/ /var/www/html/
```

> 👉🏻 Info: The startup directory already includes a script called `99-greeting` that prints a welcome message when the container starts:

```
      _    _                      _                _       _
 ___ | |_ |_| ___  ___  ___  ___ | |_  ___  ___   / | ___ | |_  ___
|_ -||   || ||   ||_ -|| -_||   ||  _|| -_||  _| / / | . ||   || . |
|___||_|_||_||_|_||___||___||_|_||_|  |___||_|  |_/  |  _||_|_||  _|
                                                     |_|       |_|
Github:    https://code.shin.company/php
DockerHub: https://docker.shin.company/php

(To edit this welcome message, add your text to /etc/welcome.txt)

---------------
Container     : shinsenter/php (built: 2024-07-24T06:19:06+0000)
Distro        : Debian GNU/Linux 12 (bookworm)
Timezone      : UTC (GMT+0000)
UID / GID     : www-data:www-data (33:33)
App Root      : /var/www/html
Document Root : /var/www/html
---------------

PHP Docker Images (https://hub.docker.com/r/shinsenter/php)
Copyright (C) 2024  SHIN Company <shin@shin.company>

This is free software under the GNU GPL.
You can redistribute and/or modify it under the terms of the GNU GPL.
This program is distributed in the hope it will be useful,
but WITHOUT ANY WARRANTY. See the GNU GPL for more details.

To get support, please contact: SHIN Company <shin@shin.company>

PHP 8.3.9 (cli) (built: Jul 23 2024 06:02:10) (NTS)
Copyright (c) The PHP Group
Zend Engine v4.3.9, Copyright (c) Zend Technologies
    with Zend OPcache v8.3.9, Copyright (c), by Zend Technologies
Composer version 2.7.7 2024-06-10 22:11:12
```

#### Disable autorun scripts

To disable autorunning scripts, set the `DISABLE_AUTORUN_SCRIPTS` environment variable to `1`.

For example, you can do this with `docker run`:
```shell
docker run -e DISABLE_AUTORUN_SCRIPTS=1 shinsenter/php:8.3-fpm-nginx
```

Or in a `docker-compose.yml`:
```yaml
services:
  web:
    image: shinsenter/php:8.3-fpm-nginx
    environment:
      - DISABLE_AUTORUN_SCRIPTS=1
```

## Debug mode

Sometimes you may need a "debug mode" for more verbose logging.

You can pass `DEBUG=1` as an environment variable to the container for more verbose logging.
The application can check for this and enable debug mode, outputting more logs.

This works both with `docker run` and in `docker-compose.yml`.

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

These Docker images also include other environment variables for fine-tuning the behavior of the container.

| Setting Name                       | Default Value | Description                                                      | Example |
|------------------------------------|---------------|------------------------------------------------------------------|---------|
| `ALLOW_RUNTIME_PHP_ENVVARS`        | Not set       | When set to "1", you can use `PHP_*` environment variables to dynamically change the configurations when running PHP commands in the container. | 1 |
| `DEBUG` or `DEBUG_MODE`            | Not set       | When set to "1", this enables debug mode with more verbose logs. | 1 |
| `TZ`                               | `UTC`         | Sets the default timezone to be used for the container. View the [full list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) here. | `Asia/Tokyo` |
| `DISABLE_AUTORUN_CREATING_PROJECT` | Not set       | When set to "1", this disables creating a new project. By default, Composer will create a project when the `INITIAL_PROJECT` environment variable is set and if the app directory is empty. | 0 |
| `INITIAL_PROJECT`                  | Not set       | When set and the app directory is empty, Composer will create a project in the app directory. | `laravel/laravel` |
| `DISABLE_AUTORUN_COMPOSER_INSTALL` | Not set       | When set to "1", this disables running `composer install` at startup. By default, `composer install` will run at container startup (only when `composer.json` is present but packages are missing). | 0 |
| `DISABLE_AUTORUN_GENERATING_INDEX` | Not set       | When set to "1", this disables creating `index.php`. By default, an `index.php` will be created in the `DOCUMENT_ROOT` directory if it doesn't exist. | 0 |
| `DISABLE_AUTORUN_SCRIPTS`          | Not set       | When set to "1", this disables all autorun scripts. | 0 |
| `ENABLE_CRONTAB`                   | Not set       | When set to "1", this enables the Crontab service. When Crontab is enabled, it also loads settings from the directory defined by the `CRONTAB_DIR` environment variable (default is `/etc/crontab.d`). | 1 |
| `CRONTAB_DIR`                      | `/etc/crontab.d` | Specifies the directory that contains settings for cron jobs. Cron jobs defined in this directory will be run as the user defined by `$APP_USER`. | `/path/to/myapp/schedules` |
| `CRONTAB_HOME`                     | `$APP_PATH`   | Specifies the `$HOME` directory to be used for cron jobs. | `/path/to/myapp` |
| `CRONTAB_MAILTO`                   | Not set       | Specifies the email address to which logs from cron jobs will be sent. | `admin@example.com` |
| `CRONTAB_PATH`                     | `$PATH`       | Sets the directory paths that programs are looked in when executing cron jobs. | `/path/to/myapp/bin` |
| `CRONTAB_SHELL`                    | `/bin/sh`     | Sets the default shell to be used for the cron tabs. | `/bin/bash` |
| `CRONTAB_TZ`                       | `$TZ`         | Sets the default timezone to be used for the cron tabs. View the [full list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) here. | `Asia/Tokyo` |
| `ENABLE_TUNING_FPM`                | Not enabled   | When set to "1", this enables auto-tuning of PM control settings.  | 0 |
| `ENABLE_TUNING_MPM`                | Not enabled   | When set to "1", this enables auto-tuning of Apache MPM settings.  | 0 |
| `FIX_APP_PATH_PERMISSION`          | Not set       | When set to "1", this corrects the ownership of the app directory. | 1 |
| `DISABLE_GREETING`                 | Not set       | When set to "1", this disables showing the welcome message when the container starts. | 0 |

## Supported Platforms

Check our [Docker Hub](https://hub.docker.com/r/shinsenter/php/tags) for all available platforms.

> 💡 Hint: Docker image tags ending in `-alpine` or `-tidy` indicate Docker images built on the Alpine Linux base operating system.
> These Docker images are lightweight, helping to speed up builds and save bandwidth for your CI/CD pipelines.

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
or opening an issue on [Github](https://github.com/shinsenter/php/issues/new).

Your support helps keep these images maintained and improved for the community.

## License

This project is licensed under the terms of the [GNU General Public License v3.0](https://code.shin.company/php/blob/main/LICENSE).

I appreciate you respecting my intellectual efforts in creating them.
If you intend to copy or use ideas from this project, please credit properly.

---

From Vietnam 🇻🇳 with love.

# PHP Docker Images

📦 Simplified PHP Docker images for effortless customization and extension setup.

Our Docker images cover PHP versions from 5.6 to 8.5 (beta), available in CLI, ZTS, FPM, FPM/Apache2, FPM/Nginx, RoadRunner, FrankenPHP, and Nginx Unit variants. The Docker images are available for both Debian and Alpine versions.

- Docker Hub: https://hub.docker.com/r/shinsenter/php
- GitHub Packages: https://code.shin.company/php/pkgs/container/php
- You can also find and use [other pre-built Docker images for some popular PHP applications and frameworks here](https://hub.docker.com/u/shinsenter).

[![Daily build](https://code.shin.company/php/actions/workflows/build-all.yml/badge.svg)](https://code.shin.company/php/actions/workflows/build-all.yml)


## Introduction

[![shinsenter/php](https://repository-images.githubusercontent.com/458053748/5a05c8e4-1c00-440c-98f1-2cd4548bbaa2)](https://docker.shin.company/php)

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


## Docker Image Variants

Our image tags cover PHP versions from 5.6 to 8.5 (beta),
available in `cli`, `zts`, `fpm`, `fpm-nginx`, `fpm-apache`, `roadrunner`<sup>(1)</sup>, `frankenphp`<sup>(2)</sup>, and `unit-php`<sup>(3)</sup> variants. The Docker images are available for both Debian and Alpine versions.

Examples:
- `shinsenter/php:7.2-cli`
- `shinsenter/php:7.3-zts`
- `shinsenter/php:7.4-fpm`
- `shinsenter/php:8.0-fpm-apache`
- `shinsenter/php:8.1-fpm-nginx`
- `shinsenter/php:8.2-roadrunner` <sup>(1)</sup>
- `shinsenter/php:8.3-frankenphp` <sup>(2)</sup>
- `shinsenter/php:8.4-unit-php` <sup>(3)</sup>

> <sup>(1)</sup>: PHP with RoadRunner server. The `roadrunner` variant supports PHP >= 8.0.<br>
> <sup>(2)</sup>: FrankenPHP is still in BETA. The `frankenphp` variant supports PHP >= 8.2.<br>
> <sup>(3)</sup>: PHP with Nginx Unit server. The `unit-php` variant supports PHP >= 7.4.

Explore all available tags on our [Docker Hub](https://hub.docker.com/r/shinsenter/php/tags).

For stable versions suitable for production, we also offer version tags on [another repository](https://hub.docker.com/r/shinsenter/php-archives/tags).

### Examples

You can easily run a container by copying and pasting one of these `docker run` commands:

#### CLI

```shell
# non-interactive
docker run --rm shinsenter/php:8.4-cli php -m

# interactive
docker run -it -v ./myproject:/var/www/html shinsenter/php:8.4-cli
```

#### PHP-FPM

```shell
docker run -v ./myproject:/var/www/html -p 9000:9000 shinsenter/php:8.4-fpm
```

#### PHP-FPM + Nginx (or Apache, RoadRunner, FrankenPHP, Nginx Unit)

```shell
# with Nginx
docker run -v ./myproject:/var/www/html -p 80:80 -p 443:443 shinsenter/php:8.4-fpm-nginx

# with Apache
docker run -v ./myproject:/var/www/html -p 80:80 -p 443:443 shinsenter/php:8.4-fpm-apache

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
    shinsenter/php:8.4 php -i
```

#### With docker-compose.yml

```yaml
services:
  web:
    image: shinsenter/php:8.4-fpm-nginx
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
pgsql
redis
sodium
tidy
uuid
yaml
zip
```

> 👉🏻 Info: The pre-installed PHP extensions from the official Docker images are excluded from this list.

> 💡 Hint: Run `docker run --rm shinsenter/php:8.4-cli php -m` in the container
to get a list of extensions (you can replace `8.4` with a specific PHP version).


## Adding PHP Extensions

These images use a simple command called `phpaddmod` to install PHP extensions.

You don't need to run the more complex `docker-php-ext-install` command
or manually edit the `php.ini` file; `phpaddmod` handles the installation and configuration for you.

For example, in your `Dockerfile`:

```Dockerfile
FROM shinsenter/php:8.4-fpm-nginx

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
    shinsenter/php:8.4-fpm-nginx
```

This changes the web application directory to `/app`.

Moreover, the default document root
(a relative path inside the `$APP_PATH` (application directory) that contains your `index.php` file)
can be customized by setting the `$DOCUMENT_ROOT` environment variable:

```shell
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v "$PWD":/app \
    -e APP_PATH=/app \
    -e DOCUMENT_ROOT=public \
    shinsenter/php:8.4-fpm-nginx
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
    shinsenter/php:8.4-fpm-nginx
```

Or in a `docker-compose.yml`:
```yaml
services:
  web:
    image: shinsenter/php:8.4-fpm-nginx
    environment:
      APP_USER: "myapp"
      APP_UID: "5000"
```


## Autorun Scripts

Shell scripts placed in the `/startup/` directory will automatically run when the container starts, in alphabetical order by filename.
This feature can initialize projects before the main program runs, saving time by executing initialization scripts automatically.

#### Usage Example

Copy a script called `00-migration` into `/startup/` via a Dockerfile:

> Note: Ensure the script has executable permissions.

```Dockerfile
FROM shinsenter/php:8.4-cli

ADD ./autorun/00-migration /startup/00-migration
RUN chmod +x /startup/00-migration

# Add your instructions here
# For example:
# ADD --chown=$APP_USER:$APP_GROUP ./myproject/ /var/www/html/
```

> 👉🏻 Info: The startup directory already includes a script called `99-greeting` that prints a welcome message when the container starts.

```
░█▀▀░█░█░▀█▀░█▀█░█▀▀░█▀▀░█▀█░▀█▀░█▀▀░█▀▄░░░█░█▀█░█░█░█▀█
░▀▀█░█▀█░░█░░█░█░▀▀█░█▀▀░█░█░░█░░█▀▀░█▀▄░▄▀░░█▀▀░█▀█░█▀▀
░▀▀▀░▀░▀░▀▀▀░▀░▀░▀▀▀░▀▀▀░▀░▀░░▀░░▀▀▀░▀░▀░▀░░░▀░░░▀░▀░▀░░

If you find my Docker images useful, consider donating via PayPal:
 -> https://www.paypal.me/shinsenter

(To edit this welcome message, add your text to /etc/welcome.txt)

---------------
Docker Images by SHIN Company
Copyright (C) 2025 SHIN Company <shin@shin.company>

This software is free under the GNU General Public License (GPL).
You can redistribute and/or modify it under the terms of the GNU GPL.
This program is provided with the hope that it will be useful,
but it comes WITHOUT ANY WARRANTY. For more details, refer to the GNU GPL.

To get support, please contact: SHIN Company <shin@shin.company>
Docker Hub:      https://hub.docker.com/u/shinsenter
GitHub Packages: https://github.com/shinsenter?tab=packages

---------------
Container     : shinsenter/php (built: 2025-07-25T00:00:00+0000)
Distro        : Debian GNU/Linux 12 (bookworm)
Timezone      : UTC (GMT+0000)
UID / GID     : www-data:www-data (33:33)
App Root      : /var/www/html
Document Root : /var/www/html
---------------

PHP 8.5.0alpha2 (cli) (built: Jul 23 2025 21:34:52) (NTS)
Copyright (c) The PHP Group
Built by https://github.com/docker-library/php
Zend Engine v4.5.0-dev, Copyright (c) Zend Technologies
    with Zend OPcache v8.5.0alpha2, Copyright (c), by Zend Technologies
Composer version 2.8.10 2025-07-10 19:08:33
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
      DISABLE_AUTORUN_SCRIPTS: "1"
```


## Using Cron Jobs

> **Note**: This is a supporting feature. If you require more advanced capabilities beyond basic `crontab` functionality, please consider building your own Docker image and installing an alternative scheduling tool (e.g., [supercronic](https://github.com/aptible/supercronic)) that better suits your needs.

To enable cron jobs in containers, you can start the container with `ENABLE_CRONTAB=1`.
This setting activates the Crontab service, which loads settings from the directory specified by `$CRONTAB_DIR` (default is `/etc/crontab.d`).

The cron jobs will run as the user defined by `$APP_USER:$APP_GROUP`, which by default is `www-data:www-data`,
and with the home directory set by `$CRONTAB_HOME` (default is `/var/www/html`).

Here is an example Dockerfile to add a crontab:

```Dockerfile
FROM shinsenter/php:latest

ENV ENABLE_CRONTAB=1

# create crontab entry via RUN instruction
RUN echo '* * * * * echo "echo This line will run every minute!" | tee /tmp/cron-every-minute.txt' >> /etc/crontab.d/sample1;

# or copy crontab entries via ADD instruction
ADD ./sample2 /etc/crontab.d/
```

The format of a crontab entry is as follows:

```
# Job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  *  command to be executed
```

You can also easily set up cron jobs through the `$CRONTAB_SETTINGS` environment variable in the `docker-compose.yml` file.
When the container starts, these settings are loaded into crontab, giving you more flexibility to change them later.

```yml
services:
  web:
    image: shinsenter/php:8.4-fpm-nginx
    environment:
      ENABLE_CRONTAB: "1"
      CRONTAB_SETTINGS: "* * * * * echo 'This line will run every minute!' | tee /tmp/cron-every-minute.txt"
```

For more information on environment variables for cron jobs, refer to the [Other System Settings](#other-system-settings) section below.


## Customize Supervisor Command

We can set a `$SUPERVISOR_PHP_COMMAND` environment variable to the service definition in your application's `docker-compose.yml` file.
This environment variable will contain the command that the container will use to serve your application using another process instead of the default process.

#### Command Line

```shell
docker run \
    -e SUPERVISOR_PHP_COMMAND='php -S localhost:80 index.php' \
    shinsenter/php:8.4
```

#### With docker-compose.yml

```yml
services:
  web:
    image: shinsenter/php:8.4
    environment:
      SUPERVISOR_PHP_COMMAND: "php -S localhost:80 index.php"
```


## Sending Emails

In these Docker images, `sendmail` has been replaced by `msmtp` for sending emails.
You can send emails using common PHP libraries like [PHPMailer](https://github.com/PHPMailer/PHPMailer).

If you prefer to use PHP's `mail()` function,
you'll need to configure SMTP using the following environment variables in your container:

| Environment Variable | Description                                     | Example Value        |
|----------------------|-------------------------------------------------|----------------------|
| `SMTP_HOST`          | The hostname or IP address of the SMTP server.  | `smtp.gmail.com`     |
| `SMTP_PORT`          | Port number used to connect to the SMTP server. | `587`                |
| `SMTP_LOG`           | File path to store SMTP email logs.             | `/path/to/email.log` |
| `SMTP_FROM`          | The sender's email address.                     | `admin@example.com`  |
| `SMTP_USER`          | Username used for SMTP authentication.          | `your_smtp_username` |
| `SMTP_PASSWORD`      | Password used for SMTP authentication.          | `your_smtp_password` |
| `SMTP_AUTH`          | Whether SMTP authentication is required.        | `on`                 |
| `SMTP_TLS`           | Whether to use TLS for secure connection.       | `on`                 |

> 💡 Hint: If you don't have an SMTP server available (like Gmail) to send emails,
> you can try using another container such as [Mailpit](https://hub.docker.com/r/axllent/mailpit) to act as an SMTP server.
>
> If you're using Mailpit, you only need to set the following two environment variables
> in your container: `SMTP_HOST=mailpit` and `SMTP_PORT=1025`.


## Debug Mode

Enable "debug mode" for more verbose logging by setting `DEBUG=1` as an environment variable.
This can be used both with `docker run` and in `docker-compose.yml`.

#### Command Line

```shell
docker run -e DEBUG=1 shinsenter/php:8.4-fpm-nginx
```

#### With docker-compose.yml

```yml
services:
  web:
    image: shinsenter/php:8.4-fpm-nginx
    environment:
      DEBUG: "1"
```


## Other System Settings

These Docker images include additional environment variables for fine-tuning container behavior:

| Setting Name                       | Default Value    | Description           | Example |
|------------------------------------|------------------|-----------------------|---------|
| `DEFAULT_LOG_PATH`                 | `/proc/1/fd/2`   | Specifies where logs are written. By default, logs are sent to the container’s standard output. | `/var/log/container.txt` |
| `DEBUG` or `DEBUG_MODE`            | Not set          | Enables verbose logging when set to `1`. | `1` |
| `TZ`                               | `UTC`            | Sets the container’s default timezone. See the [full list of timezones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones). | `Asia/Tokyo` |
| `ALLOW_RUNTIME_PHP_ENVVARS`        | Not set          | Allows `$PHP_*` environment variables to override PHP configurations at runtime. | `1` |
| `INITIAL_PROJECT`                  | Not set          | Specifies the Composer project to create if the application directory is empty.<br>※ If the value is a URL ending in `*.zip`, `*.tar.gz` or `*.git`, the container will download and extract the archive to the application directory. | `laravel/laravel` |
| `INITIAL_PROJECT_GIT_OPTIONS`      | Not set          | The parameter will be passed to the `git clone` command if `$INITIAL_PROJECT` is set and is a URL ending with `.git`. | `-b develop` |
| `DISABLE_AUTORUN_SCRIPTS`          | Not set          | Disables all autorun scripts when set to `1`. | `1` |
| `DISABLE_AUTORUN_CREATING_PROJECT` | Not set          | Prevents automatic project creation when set to `1`. By default, Composer will create a project if `$INITIAL_PROJECT` is set and the application directory is empty. | `1` |
| `DISABLE_AUTORUN_COMPOSER_INSTALL` | Not set          | Skips `composer install` during startup when set to `1`. By default, the command runs if `composer.json` exists but dependencies are missing. | `1` |
| `DISABLE_AUTORUN_GENERATING_INDEX` | Not set          | Skips creation of `index.php` when set to `1`. By default, an `index.php` file is generated in `$DOCUMENT_ROOT` if it doesn't already exist. | `1` |
| `DISABLE_AUTORUN_FIX_OWNER_GROUP`  | Not set          | Disables automatic correction of ownership for the application directory when set to `1`. | `1` |
| `DISABLE_GREETING`                 | Not set          | Suppresses the startup greeting message when set to `1`. | `1` |
| `COMPOSER_OPTIMIZE_AUTOLOADER`     | Not set          | When set to `1`, enables Composer's optimized autoloader (`--optimize-autoloader`) during install, improving performance in production. | `1` |
| `ENABLE_CRONTAB`                   | Not set          | Enables the Crontab service when set to `1`, loading job definitions from `$CRONTAB_DIR` (default: `/etc/crontab.d`). | `1` |
| `ENABLE_CRONTAB_DEBUG`             | Not set          | When set to `1`, adds a debug cron job that runs every minute and prints environment variables visible to cron. | `1` |
| `CRONTAB_DIR`                      | `/etc/crontab.d` | Directory where cron job definitions are located. Jobs run as the user specified in `$APP_USER`. | `/path/for/crontab/schedules` |
| `CRONTAB_HOME`                     | `$APP_PATH`      | Sets the `$HOME` directory used during cron job execution. | `/path/for/crontab` |
| `CRONTAB_MAILTO`                   | Not set          | Email address to receive cron job output. | `admin@example.com` |
| `CRONTAB_PATH`                     | `$PATH`          | Defines the executable search path used by cron jobs. | `/path/for/crontab/bin` |
| `CRONTAB_SETTINGS`                 | Not set          | Allows defining cron jobs directly in `docker-compose.yml`, making it easy to manage scheduled tasks inside the container. | `0 0 * * * echo "Hello new day!"` |
| `CRONTAB_SHELL`                    | `/bin/sh`        | Specifies the default shell used for cron job execution. | `/bin/bash` |
| `CRONTAB_TZ`                       | `$TZ`            | Sets the timezone for cron jobs. See the [full list of timezones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones). | `Asia/Tokyo` |
| `SUPERVISOR_PHP_COMMAND`           | Not set          | Overrides the container’s default entrypoint with a custom PHP command to serve the application. | `php -S localhost:80 index.php` |
| `ENABLE_TUNING_FPM`                | Not enabled      | Enables automatic tuning of PHP-FPM settings when set to `1`. | `1` |
| `ENABLE_TUNING_MPM`                | Not enabled      | Enables automatic tuning of Apache MPM settings when set to `1`. | `1` |


## Supported Platforms

Check our [Docker Hub](https://hub.docker.com/r/shinsenter/php/tags) for all available platforms. The Docker images are available for both Debian and Alpine versions.


## Stable Image Tags

The release versions on [this GitHub repository](https://code.shin.company/php) don't guarantee
that Docker images built from the same source code will always be identical.

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
or opening an issue on [GitHub](https://code.shin.company/php/issues/new).

Your support helps maintain and improve these images for the community.


## License

This project is licensed under the terms of the [GNU General Public License v3.0](https://code.shin.company/php/blob/main/LICENSE).

Please respect the intellectual efforts involved in creating these images.
If you intend to copy or use ideas from this project, proper credit is appreciated.

---

From Vietnam 🇻🇳 with love.

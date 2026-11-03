# PHP Docker Images <!-- omit from toc -->
📦 Lightweight PHP Docker images designed for easy customization and simple extension management.

Lightweight images for PHP 5.6 to 8.6 (RC) on Debian and Alpine.

- Docker Hub: https://hub.docker.com/r/shinsenter/php
- GitHub Packages: https://code.shin.company/php/pkgs/container/php
- You can also find other pre-built images for popular PHP applications and frameworks here: https://hub.docker.com/u/shinsenter

[![Build all](https://code.shin.company/php/actions/workflows/build-all.yml/badge.svg)](https://code.shin.company/php/actions/workflows/build-all.yml)
[![Watch updates](https://code.shin.company/php/actions/workflows/watch-updates.yml/badge.svg)](https://code.shin.company/php/actions/workflows/watch-updates.yml)


## Table of Contents <!-- omit from toc -->
- [Introduction](#introduction)
- [Getting Started](#getting-started)
  - [Docker image variants](#docker-image-variants)
- [Configuration](#configuration)
  - [Environment variables](#environment-variables)
  - [Customizing PHP-FPM](#customizing-php-fpm)
  - [Application Directory](#application-directory)
  - [User and group](#user-and-group)
- [Extending the Images](#extending-the-images)
  - [Pre-installed PHP Extensions](#pre-installed-php-extensions)
  - [Adding PHP Extensions](#adding-php-extensions)
  - [Hooks](#hooks)
  - [Autorun Scripts](#autorun-scripts)
  - [Using Cron Jobs](#using-cron-jobs)
  - [Supervisor command](#supervisor-command)
- [Operations](#operations)
  - [Sending Emails](#sending-emails)
  - [Debug mode](#debug-mode)
  - [System settings](#system-settings)
- [About This Project](#about-this-project)
  - [Supported Platforms](#supported-platforms)
  - [Stable Image Tags](#stable-image-tags)
  - [How Images Are Updated](#how-images-are-updated)
  - [Contributing](#contributing)
  - [License](#license)


## Introduction

[![shinsenter/php](https://repository-images.githubusercontent.com/458053748/58e1c323-ab0b-46d2-94d2-f5472908e7f5)](https://docker.shin.company/php)

These images are based on the [official PHP Docker images](https://hub.docker.com/_/php) and make it easy to change PHP and PHP-FPM settings using environment variables. No image rebuild required.

They include the latest Composer and common web servers - [Apache2](https://httpd.apache.org), [Nginx](https://nginx.org), [RoadRunner](https://roadrunner.dev), and [FrankenPHP](https://frankenphp.dev) - so you don't need to install them separately.

> [!NOTE]
> We slim these images down with the [docker-squash](https://code.shin.company/docker-squash) project, so pulls are faster and they use less disk and memory than the official images they're based on.


## Getting Started

### Docker image variants

Tags cover PHP versions from 5.6 to 8.6-rc and come in `cli`, `zts`, `fpm`, `fpm-nginx`, `fpm-apache`, `roadrunner`<sup>(1)</sup>, and `frankenphp`<sup>(2)</sup> variants. Both Debian and Alpine builds are available.

Examples:
- `shinsenter/php:8.3-cli`
- `shinsenter/php:8.4-zts`
- `shinsenter/php:8.5-fpm`
- `shinsenter/php:8.1-fpm-apache`
- `shinsenter/php:8.2-fpm-nginx`
- `shinsenter/php:8.3-roadrunner` <sup>(1)</sup>
- `shinsenter/php:8.4-frankenphp` <sup>(2)</sup>

> <sup>(1)</sup> RoadRunner variant - requires PHP >= 8.0.<br>
> <sup>(2)</sup> FrankenPHP variant is BETA - requires PHP >= 8.2.<br>

See all tags on our [Docker Hub](https://hub.docker.com/r/shinsenter/php/tags).


#### Examples

Run a container using one of these commands:


##### CLI

```shell
# non-interactive
docker run --rm shinsenter/php:8.5-cli php -m

# interactive
docker run -it -v ./myproject:/var/www/html shinsenter/php:8.5-cli
```


##### PHP-FPM

```shell
docker run -v ./myproject:/var/www/html -p 9000:9000 shinsenter/php:8.5-fpm
```


##### PHP-FPM + Nginx (or Apache, RoadRunner, FrankenPHP)

```shell
# with Nginx
docker run -v ./myproject:/var/www/html -p 80:80 -p 443:443 shinsenter/php:8.5-fpm-nginx

# with Apache
docker run -v ./myproject:/var/www/html -p 80:80 -p 443:443 shinsenter/php:8.5-fpm-apache

# with RoadRunner
docker run -v ./myproject:/var/www/html -p 80:80 -p 443:443 shinsenter/php:8.4-roadrunner

# with FrankenPHP
docker run -v ./myproject:/var/www/html -p 80:80 -p 443:443 shinsenter/php:8.4-frankenphp
```


## Configuration

### Environment variables

You can configure PHP and PHP-FPM using environment variables instead of rebuilding images.

Naming rules:
- Variables start with `PHP_` to avoid conflicts.
- The remainder matches the php.ini or php-fpm.conf directive name.
  - PHP ini directives: https://www.php.net/manual/en/ini.list.php
  - PHP-FPM directives: https://www.php.net/manual/en/install.fpm.configuration.php
- Directive names are converted to CONSTANT_CASE (uppercase with underscores replacing dots or dashes).

This convention lets you map any environment variable straight back to its ini/fpm directive.

> [!NOTE]
> By default, `$PHP_*` variables are applied only if set before the container starts. To allow changing PHP settings from an interactive shell inside a running container, start the container with `ALLOW_RUNTIME_PHP_ENVVARS=1`.

> [!TIP]
> Run `php-envvars` inside the container to list the default `$PHP_*` variables.


#### Examples


##### Command Line

```shell
docker run \
    -v ./myproject:/var/www/html \
    -e PHP_DISPLAY_ERRORS='1' \
    -e PHP_POST_MAX_SIZE='100M' \
    -e PHP_UPLOAD_MAX_FILESIZE='100M' \
    -e PHP_SESSION_COOKIE_HTTPONLY='1' \
    shinsenter/php:8.5 php -i
```


##### With docker-compose.yml

```yaml
services:
  web:
    image: shinsenter/php:8.5-fpm-nginx
    environment:
      PHP_DISPLAY_ERRORS: "1"
      PHP_POST_MAX_SIZE: "100M"
      PHP_UPLOAD_MAX_FILESIZE: "100M"
      PHP_SESSION_COOKIE_HTTPONLY: "1"
```


##### Explanation

| Environment Variable          | What it does                                      | Equivalent php.ini / fpm setting |
|-------------------------------|---------------------------------------------------|----------------------------------|
| PHP_DISPLAY_ERRORS=1          | Show errors during development                    | `display_errors = 1`             |
| PHP_POST_MAX_SIZE=100M        | Set max POST size (default 8M)                    | `post_max_size = 100M`           |
| PHP_UPLOAD_MAX_FILESIZE=100M  | Set max upload file size (default 2M)             | `upload_max_filesize = 100M`     |
| PHP_SESSION_COOKIE_HTTPONLY=1 | Enable HttpOnly on session cookies                | `session.cookie_httponly = 1`    |

### Customizing PHP-FPM

The images start PHP-FPM with one generated file, `/usr/local/etc/php-fpm.d/zz-docker-shinsenter-php.conf`. They do not load `php-fpm.conf` or the other files in `/usr/local/etc/php-fpm.d/`, so a mounted `www.conf` has no effect. These sources apply, and the first one wins:

1. `custom-*.conf` files in `/usr/local/etc/php-fpm.d/`.
2. `PHP_*` variables you pass to the container.
3. `ENABLE_TUNING_FPM=1`, which sets the `pm.*` values from the CPU limit of the container. A `PHP_PM*` variable you pass replaces the matching tuned value, and the other tuned values follow `PHP_PM_MAX_CHILDREN`.
4. The defaults of the image.

`PHP_*` variables are the main way to configure PHP-FPM. If you prefer a file, mount it with a name that matches `custom-*.conf`. The container looks for these files when it starts, so restart it after you add one. A pool with the same name as the generated one (`[www]`) is merged, and your values win:

```shell
docker run -v ./custom-www.conf:/usr/local/etc/php-fpm.d/custom-www.conf:ro \
    shinsenter/php:8.3-fpm
```

```ini
[www]
pm = static
pm.max_children = 10
slowlog = /var/log/php-slow.log
```


### Application Directory

Default application directory: `/var/www/html`. Change it with `$APP_PATH`:

```shell
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v "$PWD":/app \
    -e APP_PATH=/app \
    shinsenter/php:8.5-fpm-nginx
```

To change the document root (a path inside `$APP_PATH` that contains `index.php`), set `$DOCUMENT_ROOT`:

```shell
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v "$PWD":/app \
    -e APP_PATH=/app \
    -e DOCUMENT_ROOT=public \
    shinsenter/php:8.5-fpm-nginx
```

This example sets the document root to `/app/public`.


### User and group

Override the default user and group with environment variables:

| Environment Variable | Description                     | Default        |
|----------------------|---------------------------------|----------------|
| `APP_USER`           | Username inside the container   | `www-data`     |
| `APP_GROUP`          | Group name inside the container | `www-data`     |
| `APP_UID`            | Numeric UID for the user        | UID in container |
| `APP_GID`            | Numeric GID for the group       | GID in container |

Example (run as user `myapp` with UID 5000):

```shell
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -e APP_USER=myapp \
    -e APP_UID=5000 \
    shinsenter/php:8.5-fpm-nginx
```


## Extending the Images

### Pre-installed PHP Extensions

Common PHP extensions are pre-installed so projects can start quickly.

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

> [!NOTE]
> Extensions that are already included in the official PHP images are not listed here.

> [!TIP]
> Run `docker run --rm shinsenter/php:8.5-cli php -m` (replace `8.5` as needed) to see installed extensions.


### Adding PHP Extensions

Use the `phpaddmod` helper to install and configure extensions in one step - no need for `docker-php-ext-install` or manual php.ini edits.

Example Dockerfile:

```Dockerfile
FROM shinsenter/php:8.5-fpm-nginx

# Install imagick, swoole and xdebug
RUN phpaddmod imagick swoole xdebug

# Add your instructions here
# For example:
# ADD --chown=$APP_USER:$APP_GROUP ./myproject/ /var/www/html/
```

> [!NOTE]
> `phpaddmod` is a wrapper around the [`mlocati/docker-php-extension-installer`](https://github.com/mlocati/docker-php-extension-installer), which handles compiling and enabling extensions.

> [!TIP]
> See the supported extensions in their documentation: https://github.com/mlocati/docker-php-extension-installer/blob/master/README.md#supported-php-extensions


### Hooks

Hooks let you customize runtime behavior. Create a `hooks` folder inside `$APP_PATH` and place executable files named after each hook (or use subfolders).

Supported hooks:

| Hook name   | When it runs                                           | Example use                |
|-------------|--------------------------------------------------------|----------------------------|
| `onboot`    | At container start or restart                          | Send startup notification  |
| `first-run` | Only the first time the container starts               | Initialize database        |
| `rebooted`  | Every container restart                                | Check crash logs           |
| `migration` | Run database migrations                                | Apply DB migrations        |
| `onready`   | After `migration`, when the app is almost ready        | Warm up caches             |
| `onlive`    | After the web server starts (if included)              | Trigger a webhook          |

Example: To install PHP modules on first run, add `hooks/first-run` or `hooks/first-run/install-modules`.

Enable `DEBUG=1` to see which hooks run.


### Autorun Scripts

Place shell scripts in `/startup/` to run automatically when the container starts. Scripts run in alphabetical order by filename.

Example Dockerfile to add an autorun script:

> [!IMPORTANT]
> Ensure the script is executable.

```Dockerfile
FROM shinsenter/php:8.5-cli

ADD ./autorun/00-migration /startup/00-migration
RUN chmod +x /startup/00-migration

# Add your instructions here
# For example:
# ADD --chown=$APP_USER:$APP_GROUP ./myproject/ /var/www/html/
```

> [!NOTE]
> The startup directory includes `99-greeting`, which prints a welcome message at startup.


#### Disable Autorun Scripts

To disable autorun scripts, set `DISABLE_AUTORUN_SCRIPTS=1`:

```shell
docker run -e DISABLE_AUTORUN_SCRIPTS=1 shinsenter/php:8.5-cli bash
```


### Using Cron Jobs

This project supports simple cron jobs; build a custom image for advanced cron features.

Enable cron with `ENABLE_CRONTAB=1`. The service loads jobs from `$CRONTAB_DIR` (default: `/etc/crontab.d`) and runs them as `$APP_USER:$APP_GROUP` (default `www-data:www-data`), with `$CRONTAB_HOME` (default: `/var/www/html`) as the home directory.

Example Dockerfile to add a crontab:

```Dockerfile
FROM shinsenter/php:latest

ENV ENABLE_CRONTAB=1

# create crontab entry via RUN instruction
RUN echo '* * * * * echo "This line will run every minute!" | tee /tmp/cron-every-minute.txt' >> /etc/crontab.d/sample1;

# or copy crontab entries via ADD instruction
ADD ./sample2 /etc/crontab.d/
```

Crontab entry format:

```
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,...
# |  |  |  |  .---- day of week (0 - 6) OR sun,mon,...
# |  |  |  |  |
# *  *  *  *  *  command to be executed
```

You can set cron jobs directly via the `CRONTAB_SETTINGS` environment variable in docker-compose:

```yml
services:
  web:
    image: shinsenter/php:8.5-fpm-nginx
    environment:
      ENABLE_CRONTAB: "1"
      CRONTAB_SETTINGS: "* * * * * echo 'This line will run every minute!' | tee /tmp/cron-every-minute.txt"
```

For more cron-related variables, see [System settings](#system-settings).


### Supervisor command

Set `SUPERVISOR_PHP_COMMAND` to override the default command used by the supervisor process. This lets you run a different command to serve your app.

```shell
docker run \
    -e SUPERVISOR_PHP_COMMAND='php -S localhost:80 index.php' \
    shinsenter/php:8.5
```


## Operations

### Sending Emails

We use `msmtp` as a lightweight sendmail replacement, so libraries like [PHPMailer](https://github.com/PHPMailer/PHPMailer) work out of the box.

To use PHP's `mail()` function, configure SMTP via these environment variables:

| Environment Variable | Description                             | Example Value        |
|----------------------|-----------------------------------------|----------------------|
| `SMTP_HOST`          | SMTP server hostname or IP              | `smtp.gmail.com`     |
| `SMTP_PORT`          | SMTP port                               | `587`                |
| `SMTP_LOG`           | Path to SMTP log file                   | `/path/to/email.log` |
| `SMTP_FROM`          | Sender email address                    | `admin@example.com`  |
| `SMTP_USER`          | SMTP username                           | Your smtp username  |
| `SMTP_PASSWORD`      | SMTP password                           | Your smtp password  |
| `SMTP_AUTH`          | Enable SMTP authentication (`on`/`off`) | `on`                 |
| `SMTP_TLS`           | Use TLS for the connection (`on`/`off`). On by default when `SMTP_USER` or `SMTP_PASSWORD` is set | `on`                 |

> [!TIP]
> If you don't have an SMTP server, try using a local SMTP container like [Mailpit](https://hub.docker.com/r/axllent/mailpit). With Mailpit, set `SMTP_HOST=mailpit` and `SMTP_PORT=1025` in your container.


### Debug mode

Set `DEBUG=1` to turn on verbose logging and to see which hooks run:

```shell
docker run -e DEBUG=1 shinsenter/php:8.5-fpm-nginx
```


### System settings

Environment variables for fine-tuning container behavior.

#### General

| Setting Name | Default Value | Description | Example |
|---|---|---|---|
| `DEFAULT_LOG_PATH`                 | `/proc/1/fd/2`   | Where logs are written. By default, logs are sent to the container's stdout. | `/var/log/container.txt` |
| `DEBUG` or `DEBUG_MODE`            | Not set          | Enable verbose logging when set to `1`.                                      | `1`     |
| `TZ`                               | `UTC`            | Set the container's timezone. See the list of timezones.                     | `Asia/Tokyo` |
| `ALLOW_RUNTIME_PHP_ENVVARS`        | Not set          | Allow `$PHP_*` variables to override PHP configuration at runtime.           | `1`     |
| `DISABLE_GREETING`                 | Not set          | Suppress the startup greeting with `1`.                                      | `1`     |
| `ENABLE_SSHD`                      | Not set          | Enable SSH server inside the container when `1`.                             | `1`     |
| `SSHD_AUTHORIZED_KEYS`             | Not set          | Public SSH keys (one per line). When not empty, they replace the content of `~/.ssh/authorized_keys` at every start. | `ssh-rsa AAAA...` |
| `SUPERVISOR_PHP_COMMAND`           | Not set          | Override the PHP command used by supervisor. Quotes group arguments that contain spaces. | `php -S localhost:80 index.php` |


#### Project startup and autorun

| Setting Name | Default Value | Description | Example |
|---|---|---|---|
| `INITIAL_PROJECT`                  | Not set          | Used only when the app directory is empty. A URL starting with `http` and ending in `.zip` or `.tar.gz` is downloaded and extracted. A URL ending in `.git` is cloned. A value like `vendor/package` is created with `composer create-project`. Any other value runs the `create-project` hook. | `https://example.com/project.zip` |
| `INITIAL_PROJECT_GIT_OPTIONS`      | Not set          | Options passed to `git clone` when `INITIAL_PROJECT` is a `http*.git` URL.   | `-b develop` |
| `DISABLE_AUTORUN_SCRIPTS`          | Not set          | Set to `1` to disable autorun scripts.                                       | `1`     |
| `DISABLE_AUTORUN_CREATING_PROJECT` | Not set          | Do not create a project from `INITIAL_PROJECT` when `1`. It does not stop copying `/source/`. | `1`     |
| `DISABLE_AUTORUN_COPYING_SOURCE`   | Not set          | Do not copy the files of `/source/` into the app directory when `1`. The copy runs only when the app directory is empty. | `1`     |
| `DISABLE_AUTORUN_COMPOSER_INSTALL` | Not set          | Skip running `composer install` during startup when set to `1`. It does not stop `COMPOSER_OPTIMIZE_AUTOLOADER`. | `1`     |
| `DISABLE_AUTORUN_GENERATING_INDEX` | Not set          | Do not generate `index.php` when set to `1`.                                 | `1`     |
| `DISABLE_AUTORUN_FIX_OWNER_GROUP`  | Not set          | When `1`, no command changes the owner of files in `APP_PATH` or `DOCUMENT_ROOT`: no ownership fix, no owner on created directories, and no UID/GID migration there. Files and directories the container creates there, such as a missing `DOCUMENT_ROOT` or `index.php`, belong to root, so set the owner of paths that `APP_USER` must write to yourself. | `1`     |
| `COMPOSER_OPTIMIZE_AUTOLOADER`     | Not set          | When `1`, run `composer dumpautoload --optimize --no-cache` at startup if `composer.lock` and the `vendor` directory exist. | `1`     |


#### Cron

| Setting Name | Default Value | Description | Example |
|---|---|---|---|
| `ENABLE_CRONTAB`                   | Not set          | Enable Crontab service when `1`. Jobs are loaded from `$CRONTAB_DIR`.        | `1`     |
| `ENABLE_CRONTAB_DEBUG`             | Not set          | Adds a debug cron job that runs every minute when `1`. When set, it takes priority over `DEBUG`, so `0` removes the job even if `DEBUG=1`. | `1`     |
| `CRONTAB_DIR`                      | `/etc/crontab.d` | Directory for crontab definitions. Jobs run as `$APP_USER`.                  | `/path/for/crontab/schedules` |
| `CRONTAB_HOME`                     | `$APP_PATH`      | Home directory for cron jobs.                                                | `/path/for/crontab` |
| `CRONTAB_MAILTO`                   | Not set          | Email address to receive cron output.                                        | `admin@example.com` |
| `CRONTAB_PATH`                     | `$PATH`          | Executable search path used by cron jobs.                                    | `/path/for/crontab/bin` |
| `CRONTAB_SETTINGS`                 | Not set          | Define cron jobs directly via environment variable.                          | `0 0 * * * echo "..."` |
| `CRONTAB_SHELL`                    | `/bin/bash`      | Default shell for cron jobs.                                                 | `/bin/bash` |
| `CRONTAB_TZ`                       | `$TZ`            | Timezone used for cron jobs.                                                 | `Asia/Tokyo` |


#### Tuning and Apache

| Setting Name | Default Value | Description | Example |
|---|---|---|---|
| `ENABLE_TUNING_FPM`                | Not enabled      | Enable automatic tuning of PHP-FPM settings when set to `1`. Uses the CPU limit of the container, or the host CPU count if there is none. A `PHP_PM*` variable you pass replaces the tuned value. See [Customizing PHP-FPM](#customizing-php-fpm). | `1`     |
| `ENABLE_TUNING_MPM`                | Not enabled      | Enable automatic tuning of Apache MPM settings when set to `1`. Uses the CPU and memory limits of the container, or the host values if there are none. | `1`     |
| `APACHE_ALLOW_OVERRIDE`            | `all`            | Value of `AllowOverride` for the document root. `none` skips reading `.htaccess` files on every request, but rules in `.htaccess` stop working. | `none` |
| `APACHE_DEFLATE_LEVEL`             | `5`              | Compression level of `mod_deflate`, from 1 (fast) to 9 (smallest). | `6` |
| `APACHE_DISABLE_MODULES`           | Not set          | Apache modules to turn off at start, separated by spaces. | `cache cgid mime_magic negotiation` |
| `APACHE_EXPIRES`                   | `access plus 1 month`| Cache lifetime that `mod_expires` sets for static file types such as CSS, JS, images and fonts. | `access plus 1 week` |
| `APACHE_KEEPALIVE_TIMEOUT`         | `5`              | Seconds that Apache keeps an idle connection open. | `2` |
| `APACHE_MPM_PROFILE`               | `balanced`       | Profile used by `ENABLE_TUNING_MPM`: `low`, `balanced` or `high`. | `high` |
| `APACHE_REFERRER_POLICY`           | `strict-origin-when-cross-origin` | Value of the `Referrer-Policy` response header. | `no-referrer` |
| `APACHE_REQUEST_READ_TIMEOUT`      | `header=20-40,MinRate=500 body=20,MinRate=500` | Value of `RequestReadTimeout`. It closes connections that send the request too slowly. | `header=10-20,MinRate=500 body=20,MinRate=500` |


## About This Project

### Supported Platforms

See the [Docker Hub tags](https://hub.docker.com/r/shinsenter/php/tags) for the platforms of each image.

> [!NOTE]
> From 2026-10-25, the rarely used platforms `linux/386`, `linux/arm/v7`, `linux/ppc64le` and `linux/s390x` are no longer built. Tags published before that date keep them until they are rebuilt.


### Stable Image Tags

For stable, production-ready images we maintain dated tags in a separate repository.

> [!NOTE]
> View stable tags: https://hub.docker.com/r/shinsenter/php-archives/tags


### How Images Are Updated

Images are no longer rebuilt on a daily schedule. The [Watch updates](https://code.shin.company/php/actions/workflows/watch-updates.yml) workflow runs every 30 minutes and compares each published image with its current inputs:

- the official `php` image of that version (new PHP release or security fix)
- Composer, docker-php-extension-installer, s6-overlay, FrankenPHP, RoadRunner
- the base OS images and the files in this repository

When an input changes, only the affected PHP versions are built again. Images that are still up to date are skipped without being pulled or built. A Composer, extension installer or s6-overlay update rebuilds the maintained versions only. Outdated versions are rebuilt when their official PHP image changes.

Each published image carries the fingerprint of its inputs in the `org.shinsenter.build.fingerprint` annotation of the image index:

```sh
docker buildx imagetools inspect --raw shinsenter/php:8.5-fpm | jq '.annotations'
```

These images are built from the official `php` image, so they can only be rebuilt after the official image for the new PHP release is published on Docker Hub. To check the PHP version in a container, run `php -v`.

Maintainers can start a build by hand from the [Build all](https://code.shin.company/php/actions/workflows/build-all.yml) workflow, with `php_versions` (for example `8.5 8.4`) and `force_build`.


### Contributing

If these images are useful to you, donate via [PayPal](https://www.paypal.me/shinsenter) or open an issue on [GitHub](https://code.shin.company/php/issues/new).


### License

This project is licensed under the [GNU General Public License v3.0](https://code.shin.company/php/blob/main/LICENSE).

Please respect the work that went into these images. If you reuse ideas from this project, credit is appreciated.

---

From Vietnam 🇻🇳 with love.

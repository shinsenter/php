# PHP Docker Images <!-- omit from toc -->
📦 Lightweight PHP Docker images designed for easy customization and simple extension management.

Our images support PHP versions from 5.6 up to 8.6 (RC), with variants for CLI, ZTS, FPM, FPM/Apache, FPM/Nginx, RoadRunner, and FrankenPHP. Images are available for both Debian and Alpine.

- Docker Hub: https://hub.docker.com/r/shinsenter/php
- GitHub Packages: https://code.shin.company/php/pkgs/container/php
- You can also find other pre-built images for popular PHP applications and frameworks here: https://hub.docker.com/u/shinsenter

[![Daily build](https://code.shin.company/php/actions/workflows/build-all.yml/badge.svg)](https://code.shin.company/php/actions/workflows/build-all.yml)


## Table of Contents <!-- omit from toc -->
- [Introduction](#introduction)
- [Docker Image Variants](#docker-image-variants)
- [Customizing Settings via Environment Variables](#customizing-settings-via-environment-variables)
- [Pre-installed PHP Extensions](#pre-installed-php-extensions)
- [Adding PHP Extensions](#adding-php-extensions)
- [Application Directory](#application-directory)
- [Customizing Container User and Group in Docker](#customizing-container-user-and-group-in-docker)
- [Hooks](#hooks)
- [Autorun Scripts](#autorun-scripts)
- [Using Cron Jobs](#using-cron-jobs)
- [Customize Supervisor Command](#customize-supervisor-command)
- [Sending Emails](#sending-emails)
- [Debug Mode](#debug-mode)
- [Other System Settings](#other-system-settings)
- [Supported Platforms](#supported-platforms)
- [Stable Image Tags](#stable-image-tags)
- [Contributing](#contributing)
- [License](#license)


## Introduction

[![shinsenter/php](https://repository-images.githubusercontent.com/458053748/5a05c8e4-1c00-440c-98f1-2cd4548bbaa2)](https://docker.shin.company/php)

These images are based on the [official PHP Docker images](https://hub.docker.com/_/php) and make it easy to change PHP and PHP-FPM settings using environment variables. No image rebuild required.

They include Composer (the latest version) and common web servers such as [Apache2](https://httpd.apache.org), [Nginx](https://nginx.org), [RoadRunner](https://roadrunner.dev), and [FrankenPHP](https://frankenphp.dev). This helps you start projects faster without extra installs.

> 🪶 Note: While based on the official images and including useful extensions, we have significantly reduced the image sizes to improve download times and resource usage, using the [docker-squash](https://code.shin.company/docker-squash) project.


## Docker Image Variants

Tags cover PHP versions from 5.6 to 8.6-rc and come in `cli`, `zts`, `fpm`, `fpm-nginx`, `fpm-apache`, `roadrunner`<sup>(1)</sup>, and `frankenphp`<sup>(2)</sup> variants. Both Debian and Alpine builds are available.

Examples:
- `shinsenter/php:8.3-cli`
- `shinsenter/php:8.4-zts`
- `shinsenter/php:8.5-fpm`
- `shinsenter/php:8.1-fpm-apache`
- `shinsenter/php:8.2-fpm-nginx`
- `shinsenter/php:8.3-roadrunner` <sup>(1)</sup>
- `shinsenter/php:8.4-frankenphp` <sup>(2)</sup>

> <sup>(1)</sup> RoadRunner variant — requires PHP >= 8.0.<br>
> <sup>(2)</sup> FrankenPHP variant is BETA — requires PHP >= 8.2.<br>

See all tags on our [Docker Hub](https://hub.docker.com/r/shinsenter/php/tags).


### Examples <!-- omit from toc -->

Run a container using one of these commands:


#### CLI <!-- omit from toc -->

```shell
# non-interactive
docker run --rm shinsenter/php:8.5-cli php -m

# interactive
docker run -it -v ./myproject:/var/www/html shinsenter/php:8.5-cli
```


#### PHP-FPM <!-- omit from toc -->

```shell
docker run -v ./myproject:/var/www/html -p 9000:9000 shinsenter/php:8.5-fpm
```


#### PHP-FPM + Nginx (or Apache, RoadRunner, FrankenPHP) <!-- omit from toc -->

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


## Customizing Settings via Environment Variables

You can configure PHP and PHP-FPM using environment variables instead of rebuilding images.

Naming rules:
- Variables start with `PHP_` to avoid conflicts.
- The remainder matches the php.ini or php-fpm.conf directive name.
  - PHP ini directives: https://www.php.net/manual/en/ini.list.php
  - PHP-FPM directives: https://www.php.net/manual/en/install.fpm.configuration.php
- Directive names are converted to CONSTANT_CASE (uppercase with underscores replacing dots or dashes).

By following this convention you can quickly identify the environment variable that maps to each configuration directive.

> 👉🏻 Note: By default, `$PHP_*` variables are applied only if set before the container starts. To allow changing PHP settings from an interactive shell inside a running container, start the container with `ALLOW_RUNTIME_PHP_ENVVARS=1`.

> 💡 Tip: Run `php-envvars` inside the container to list the default `$PHP_*` variables.


### Examples <!-- omit from toc -->


#### Command Line <!-- omit from toc -->

```shell
docker run \
    -v ./myproject:/var/www/html \
    -e PHP_DISPLAY_ERRORS='1' \
    -e PHP_POST_MAX_SIZE='100M' \
    -e PHP_UPLOAD_MAX_FILESIZE='100M' \
    -e PHP_SESSION_COOKIE_HTTPONLY='1' \
    shinsenter/php:8.5 php -i
```


#### With docker-compose.yml <!-- omit from toc -->

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


#### Explanation <!-- omit from toc -->

| Environment Variable          | What it does                                      | Equivalent php.ini / fpm setting |
|-------------------------------|---------------------------------------------------|----------------------------------|
| PHP_DISPLAY_ERRORS=1          | Show errors during development                    | `display_errors = 1`             |
| PHP_POST_MAX_SIZE=100M        | Set max POST size (default 8M)                    | `post_max_size = 100M`           |
| PHP_UPLOAD_MAX_FILESIZE=100M  | Set max upload file size (default 2M)             | `upload_max_filesize = 100M`     |
| PHP_SESSION_COOKIE_HTTPONLY=1 | Enable HttpOnly on session cookies                | `session.cookie_httponly = 1`    |

> 💡 Tip: Run `php-envvars` in the container to get a full list of default `$PHP_*` environment variables.


## Pre-installed PHP Extensions

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

> 👉🏻 Note: Extensions that are already included in the official PHP images are not listed here.

> 💡 Tip: Run `docker run --rm shinsenter/php:8.5-cli php -m` (replace `8.5` as needed) to see installed extensions.


## Adding PHP Extensions

Use the `phpaddmod` helper to install extensions easily.

You do not need to use `docker-php-ext-install` or manually edit php.ini — `phpaddmod` installs and configures extensions for you.

Example Dockerfile:

```Dockerfile
FROM shinsenter/php:8.5-fpm-nginx

# Install imagick, swoole and xdebug
RUN phpaddmod imagick swoole xdebug

# Add your instructions here
# For example:
# ADD --chown=$APP_USER:$APP_GROUP ./myproject/ /var/www/html/
```

> 👉🏻 Note: `phpaddmod` is a wrapper around the [`mlocati/docker-php-extension-installer`](https://github.com/mlocati/docker-php-extension-installer),
which handles compiling and enabling extensions.

> 💡 Tip: See the supported extensions in their documentation: https://github.com/mlocati/docker-php-extension-installer/blob/master/README.md#supported-php-extensions


## Application Directory

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


## Customizing Container User and Group in Docker

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

docker-compose example:

```yaml
services:
  web:
    image: shinsenter/php:8.5-fpm-nginx
    environment:
      APP_USER: "myapp"
      APP_UID: "5000"
```


## Hooks

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


## Autorun Scripts

Place shell scripts in `/startup/` to run automatically when the container starts. Scripts run in alphabetical order by filename.

Example Dockerfile to add an autorun script:

> Ensure the script is executable.

```Dockerfile
FROM shinsenter/php:8.5-cli

ADD ./autorun/00-migration /startup/00-migration
RUN chmod +x /startup/00-migration

# Add your instructions here
# For example:
# ADD --chown=$APP_USER:$APP_GROUP ./myproject/ /var/www/html/
```

> 👉🏻 Note: The startup directory includes `99-greeting`, which prints a welcome message at startup.


#### Disable Autorun Scripts <!-- omit from toc -->

To disable autorun scripts, set `DISABLE_AUTORUN_SCRIPTS=1`:

```shell
docker run -e DISABLE_AUTORUN_SCRIPTS=1 shinsenter/ubuntu-s6:latest bash
```

Or in docker-compose:

```yaml
services:
  web:
    image: shinsenter/ubuntu-s6:latest
    environment:
      DISABLE_AUTORUN_SCRIPTS: "1"
```


## Using Cron Jobs

This project supports simple cron jobs. For advanced cron features, consider building a custom image.

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

For more cron-related environment variables, see [Other System Settings](#other-system-settings).


## Customize Supervisor Command

Set `SUPERVISOR_PHP_COMMAND` to override the default command used by the supervisor process. This lets you run a different command to serve your app.

Command line example:

```shell
docker run \
    -e SUPERVISOR_PHP_COMMAND='php -S localhost:80 index.php' \
    shinsenter/php:8.5
```

docker-compose example:

```yml
services:
  web:
    image: shinsenter/php:8.5
    environment:
      SUPERVISOR_PHP_COMMAND: "php -S localhost:80 index.php"
```


## Sending Emails

We use `msmtp` as a lightweight sendmail replacement. You can send mail with libraries like [PHPMailer](https://github.com/PHPMailer/PHPMailer).

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
| `SMTP_TLS`           | Use TLS for the connection (`on`/`off`) | `on`                 |

> 💡 Tip: If you don't have an SMTP server, try using a local SMTP container like [Mailpit](https://hub.docker.com/r/axllent/mailpit). With Mailpit, set `SMTP_HOST=mailpit` and `SMTP_PORT=1025` in your container.


## Debug Mode

Enable verbose logging by setting `DEBUG=1` when starting the container.

Command line:

```shell
docker run -e DEBUG=1 shinsenter/php:8.5-fpm-nginx
```

docker-compose:

```yml
services:
  web:
    image: shinsenter/php:8.5-fpm-nginx
    environment:
      DEBUG: "1"
```


## Other System Settings

Additional environment variables for fine-tuning container behavior:

| Setting Name                       | Default Value    | Description                                                                  | Example |
|------------------------------------|------------------|------------------------------------------------------------------------------|---------|
| `DEFAULT_LOG_PATH`                 | `/proc/1/fd/2`   | Where logs are written. By default, logs are sent to the container's stdout. | `/var/log/container.txt` |
| `DEBUG` or `DEBUG_MODE`            | Not set          | Enable verbose logging when set to `1`.                                      | `1`     |
| `TZ`                               | `UTC`            | Set the container's timezone. See the list of timezones.                     | `Asia/Tokyo` |
| `ALLOW_RUNTIME_PHP_ENVVARS`        | Not set          | Allow `$PHP_*` variables to override PHP configuration at runtime.           | `1`     |
| `INITIAL_PROJECT`                  | Not set          | Composer project to create if the app directory is empty. If this is a URL ending in `.zip`, `.tar.gz`, or similar, the archive will be downloaded and extracted. | `https://example.com/project.zip` |
| `INITIAL_PROJECT_GIT_OPTIONS`      | Not set          | Options passed to `git clone` when `INITIAL_PROJECT` is a `.git` URL.        | `-b develop` |
| `DISABLE_AUTORUN_SCRIPTS`          | Not set          | Set to `1` to disable autorun scripts.                                       | `1`     |
| `DISABLE_AUTORUN_CREATING_PROJECT` | Not set          | Prevent automatic project creation when set to `1`.                          | `1`     |
| `DISABLE_AUTORUN_COMPOSER_INSTALL` | Not set          | Skip running `composer install` during startup when set to `1`.              | `1`     |
| `DISABLE_AUTORUN_GENERATING_INDEX` | Not set          | Do not generate `index.php` when set to `1`.                                 | `1`     |
| `DISABLE_AUTORUN_FIX_OWNER_GROUP`  | Not set          | Do not automatically fix ownership of the application directory when `1`.    | `1`     |
| `DISABLE_GREETING`                 | Not set          | Suppress the startup greeting with `1`.                                      | `1`     |
| `COMPOSER_OPTIMIZE_AUTOLOADER`     | Not set          | When `1`, run Composer with `--optimize-autoloader` for production installs. | `1`     |
| `ENABLE_SSHD`                      | Not set          | Enable SSH server inside the container when `1`.                             | `1`     |
| `SSHD_AUTHORIZED_KEYS`             | Not set          | Public SSH keys to add to `~/.ssh/authorized_keys` (one per line).           | `ssh-rsa AAAA...` |
| `ENABLE_CRONTAB`                   | Not set          | Enable Crontab service when `1`. Jobs are loaded from `$CRONTAB_DIR`.        | `1`     |
| `ENABLE_CRONTAB_DEBUG`             | Not set          | Adds a debug cron job that runs every minute when `1`.                       | `1`     |
| `CRONTAB_DIR`                      | `/etc/crontab.d` | Directory for crontab definitions. Jobs run as `$APP_USER`.                  | `/path/for/crontab/schedules` |
| `CRONTAB_HOME`                     | `$APP_PATH`      | Home directory for cron jobs.                                                | `/path/for/crontab` |
| `CRONTAB_MAILTO`                   | Not set          | Email address to receive cron output.                                        | `admin@example.com` |
| `CRONTAB_PATH`                     | `$PATH`          | Executable search path used by cron jobs.                                    | `/path/for/crontab/bin` |
| `CRONTAB_SETTINGS`                 | Not set          | Define cron jobs directly via environment variable.                          | `0 0 * * * echo "..."` |
| `CRONTAB_SHELL`                    | `/bin/sh`        | Default shell for cron jobs.                                                 | `/bin/bash` |
| `CRONTAB_TZ`                       | `$TZ`            | Timezone used for cron jobs.                                                 | `Asia/Tokyo` |
| `SUPERVISOR_PHP_COMMAND`           | Not set          | Override the PHP command used by supervisor.                                 | `php -S localhost:80 index.php` |
| `ENABLE_TUNING_FPM`                | Not enabled      | Enable automatic tuning of PHP-FPM settings when set to `1`.                 | `1`     |
| `ENABLE_TUNING_MPM`                | Not enabled      | Enable automatic tuning of Apache MPM settings when set to `1`.              | `1`     |


## Supported Platforms

See our [Docker Hub](https://hub.docker.com/r/shinsenter/php/tags) for available platforms. Images are built for both Debian and Alpine variants.


## Stable Image Tags

For stable, production-ready images we maintain dated tags in a separate repository.

> 👉🏻 View Stable Tags: https://hub.docker.com/r/shinsenter/php-archives/tags


## Contributing

If you find these images useful, consider donating via [PayPal](https://www.paypal.me/shinsenter) or open an issue on [GitHub](https://code.shin.company/php/issues/new).

Your support helps maintain and improve these images for everyone.


## License

This project is licensed under the [GNU General Public License v3.0](https://code.shin.company/php/blob/main/LICENSE).

Please respect the work that went into these images. If you reuse ideas from this project, credit is appreciated.

---

From Vietnam 🇻🇳 with love.

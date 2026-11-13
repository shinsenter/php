# PHP Docker Images <!-- omit from toc -->

📦 (PHP) Lightweight images for PHP 5.6 to 8.6, on Debian and Alpine, ready to run

- Docker Hub: https://hub.docker.com/r/shinsenter/php
- GitHub Packages: https://code.shin.company/php/pkgs/container/php
- Pre-built images for popular PHP applications and frameworks: https://hub.docker.com/u/shinsenter

[![Build all](https://code.shin.company/php/actions/workflows/build-all.yml/badge.svg)](https://code.shin.company/php/actions/workflows/build-all.yml)
[![Watch updates](https://code.shin.company/php/actions/workflows/watch-updates.yml/badge.svg)](https://code.shin.company/php/actions/workflows/watch-updates.yml)


## Table of Contents <!-- omit from toc -->
- [Introduction](#introduction)
- [Quick start](#quick-start)
- [Getting Started](#getting-started)
  - [Docker image variants](#docker-image-variants)
  - [Which tag should I use?](#which-tag-should-i-use)
  - [Ready-made application images](#ready-made-application-images)
- [Configuration](#configuration)
  - [Environment variables](#environment-variables)
  - [Customizing PHP-FPM](#customizing-php-fpm)
  - [Application Directory](#application-directory)
  - [User and group](#user-and-group)
- [Extending the Images](#extending-the-images)
  - [Pre-installed PHP extensions, hooks and autorun scripts](#pre-installed-php-extensions-hooks-and-autorun-scripts)
  - [Adding PHP Extensions](#adding-php-extensions)
  - [Using Cron Jobs](#using-cron-jobs)
  - [Supervisor command](#supervisor-command)
- [Running in Production](#running-in-production)
  - [HTTPS](#https)
  - [Behind a proxy or load balancer](#behind-a-proxy-or-load-balancer)
  - [Health checks](#health-checks)
  - [Stopping and scaling](#stopping-and-scaling)
  - [Performance](#performance)
- [Operations](#operations)
  - [Sending Emails](#sending-emails)
  - [Debug mode](#debug-mode)
  - [SSH access](#ssh-access)
  - [System settings](#system-settings)
- [About This Project](#about-this-project)
  - [Support the project](#support-the-project)
  - [License](#license)


## Introduction

[![shinsenter/php](https://repository-images.githubusercontent.com/458053748/58e1c323-ab0b-46d2-94d2-f5472908e7f5)](https://docker.shin.company/php)

These images are based on the [official PHP Docker images](https://hub.docker.com/_/php) and make it easy to change PHP and PHP-FPM settings using environment variables. No image rebuild required.

They include the latest Composer and common web servers - [Apache2](https://httpd.apache.org), [Nginx](https://nginx.org), [RoadRunner](https://roadrunner.dev), and [FrankenPHP](https://frankenphp.dev) - so you don't need to install them separately.

> [!NOTE]
> We slim these images down with the [docker-squash](https://code.shin.company/docker-squash) project, so pulls are faster and they use less disk and memory than the official images they're based on.
>
> New builds use zstd layer compression, which makes images smaller to pull. Pulling them needs Docker Engine 23.0 or later, or containerd 1.5 or later (Kubernetes included). On an older runtime the pull fails. A tag that has not been rebuilt yet keeps its gzip layers.


## Quick start

```shell
# Check the PHP version
docker run --rm shinsenter/php:8.5-cli php -v

# Serve a project with PHP-FPM and Nginx, then open http://localhost
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v ./myproject:/var/www/html \
    shinsenter/php:8.5-fpm-nginx
```

- Your code goes in `/var/www/html`.
- Change PHP settings with `PHP_*` variables, for example `-e PHP_MEMORY_LIMIT=512M`. See [Environment variables](#environment-variables).
- Mount an empty folder and set `-e INITIAL_PROJECT=laravel/laravel` to create a new project on first start.
- Test HTTPS certificates are built in. See [HTTPS](#https).


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


### Which tag should I use?

| I want to | Tag | Notes |
|---|---|---|
| Run scripts, workers or Composer | `cli` | Runs `php` and exits |
| Use thread-safe PHP | `zts` | For extensions that need ZTS |
| Put PHP-FPM behind my own web server or ingress | `fpm` | Listens on port 9000 |
| Get a ready web server | `fpm-nginx` | Nginx + PHP-FPM, ports 80 and 443 |
| Use Apache and `.htaccess` | `fpm-apache` | Apache + PHP-FPM, ports 80 and 443 |
| Use a long-running app server | `roadrunner` | PHP 8.0 or newer |
| Use a Caddy-based app server | `frankenphp` | PHP 8.2 or newer, beta |

Pick `-alpine` for the smallest size, or the Debian default for the widest package support. The tags of every variant are listed on [Docker Hub](https://hub.docker.com/r/shinsenter/php/tags).


### Ready-made application images

Images for popular frameworks and applications install the project for you on first start (mount an empty folder). The list and examples are in [docs/applications.md](https://code.shin.company/php/blob/main/docs/applications.md).

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


### Pre-installed PHP extensions, hooks and autorun scripts

The list of pre-installed extensions, the hooks and the autorun scripts are in [docs/extending.md](https://code.shin.company/php/blob/main/docs/extending.md).
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


### Using Cron Jobs

Jobs load from `$CRONTAB_DIR` when `ENABLE_CRONTAB=1`. Setup and examples are in [docs/extending.md](https://code.shin.company/php/blob/main/docs/extending.md#using-cron-jobs).


### Supervisor command

Set `SUPERVISOR_PHP_COMMAND` to override the default command used by the supervisor process. This lets you run a different command to serve your app.

```shell
docker run \
    -e SUPERVISOR_PHP_COMMAND='php -S localhost:80 index.php' \
    shinsenter/php:8.5
```


## Running in Production

These notes apply to the web images (`fpm-nginx`, `fpm-apache`, `roadrunner`, `frankenphp`) on Docker, Kubernetes, AWS, GCP or behind Traefik.

### HTTPS

The images ship a self-signed certificate for local tests:

- `/etc/ssl/site/server.crt`
- `/etc/ssl/site/server.key`

For production, mount your own files over them, or copy them in your Dockerfile:

```shell
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v ./myproject:/var/www/html \
    -v ./my_domain.crt:/etc/ssl/site/server.crt \
    -v ./my_domain.key:/etc/ssl/site/server.key \
    shinsenter/php:8.5-fpm-nginx
```

If a proxy or load balancer ends TLS for you, see the next section.


### Behind a proxy or load balancer

By default no proxy is trusted. `REMOTE_ADDR` stays the address of the connection, and your app reads `X-Forwarded-For` itself.

Set `TRUSTED_PROXIES` (CIDRs, separated by comma or space) to let the server use the client address from `X-Forwarded-For` and honor `X-Forwarded-Proto` (it then sets `$_SERVER['HTTPS']`). It works on Nginx, Apache, FrankenPHP and RoadRunner:

```shell
docker run -e TRUSTED_PROXIES='10.0.0.0/8,172.16.0.0/12,192.168.0.0/16' \
    -p 80:80 shinsenter/php:8.5-fpm-nginx
```

Only listed proxies can set these headers, so a client that connects directly cannot fake them. With Cloudflare in front, list your load balancer and the Cloudflare ranges.


### Health checks

Each web image answers health checks on a separate port, `HEALTH_PORT` (default `2020`). The port is not published by default and does not depend on the `Host` header, HTTPS redirects or your app.

| Image | Liveness | Readiness |
|---|---|---|
| `fpm-nginx`, `fpm-apache` | `/healthz` (web server only) | `/readyz` (PHP-FPM ping, path set by `PHP_PING_PATH`) |
| `frankenphp` | `/healthz` | `/readyz` |
| `roadrunner` | `/health?plugin=http` | `/ready?plugin=http` |

`HEALTH_CHECK_URL` holds the full liveness address inside the container. The images define no `HEALTHCHECK`, because a first start can clone a project or run `composer install`, and nothing answers until it ends. Set a long `start_period` (Docker) or a `startupProbe` (Kubernetes).

Docker Compose:

```yaml
services:
  web:
    image: shinsenter/php:8.5-fpm-nginx
    healthcheck:
      test: ["CMD-SHELL", "with-env sh -c 'curl -sf \"$$HEALTH_CHECK_URL\" >/dev/null'"]
      interval: 15s
      timeout: 3s
      retries: 3
      start_period: 120s
```

Kubernetes:

```yaml
startupProbe:
  httpGet: { path: /healthz, port: 2020 }
  periodSeconds: 10
  failureThreshold: 30
livenessProbe:
  httpGet: { path: /healthz, port: 2020 }
  periodSeconds: 10
readinessProbe:
  httpGet: { path: /readyz, port: 2020 }
  periodSeconds: 5
```

For load balancers, send traffic to port 80 and point the health check at port 2020, path `/readyz` (AWS ALB target group port override, GCP BackendConfig, Traefik `loadbalancer.healthcheck.port`).


### Stopping and scaling

| Variable | Default | Effect |
|---|---|---|
| `SHUTDOWN_DELAY` | `0` | Seconds to wait after the stop signal, so the load balancer can remove the replica |
| `S6_SERVICES_GRACETIME`, `S6_KILL_GRACETIME` | `25000` | Milliseconds that servers get to finish running requests. Keep it below `terminationGracePeriodSeconds` (30 s by default) |
| `CADDY_GRACE_PERIOD` | `20s` | FrankenPHP: time for running requests on stop |

On `SIGTERM` the container waits `SHUTDOWN_DELAY`, then stops the servers gracefully: running requests finish and new connections are refused.

To scale out:

- Keep sessions, uploads and cache outside the container (Redis, a database, object storage or a shared volume), so every replica can answer any request.
- Put the source and `vendor/` in the image at build time, and set `DISABLE_AUTORUN_CREATING_PROJECT=1` and `DISABLE_AUTORUN_COMPOSER_INSTALL=1`. Replicas then start fast and with the same package versions.


### Performance

The defaults suit development as well as production, so a code change shows up right away. For production, set these variables:

| Variable | Value | Effect |
|---|---|---|
| `PHP_OPCACHE_VALIDATE_TIMESTAMPS` | `0` | PHP stops checking files for changes. Restart the container after a deploy, because a changed file is not picked up |
| `ENABLE_TUNING_FPM` | `1` | Sets the `pm.*` values of PHP-FPM from the CPU limit of the container (see [Customizing PHP-FPM](#customizing-php-fpm)) |
| `COMPOSER_OPTIMIZE_AUTOLOADER` | `1` | Builds an optimized class map at startup. With `vendor/` in the image, run `composer dump-autoload --optimize` at build time instead |

```shell
docker run -p 80:80 \
    -e PHP_OPCACHE_VALIDATE_TIMESTAMPS=0 \
    -e ENABLE_TUNING_FPM=1 \
    shinsenter/php:8.5-fpm-nginx
```

Other settings that matter:

- `PHP_OPCACHE_MEMORY_CONSUMPTION` (default `256`, in MB) and `PHP_OPCACHE_MAX_ACCELERATED_FILES` (default `130987`) are enough for most projects. Raise them when `opcache_get_status()` shows a full cache.
- `PHP_OPCACHE_JIT` and `PHP_OPCACHE_JIT_BUFFER_SIZE` turn on the JIT. It helps CPU-bound code and does little for a typical web request, so measure before you keep it.
- Nginx and FrankenPHP compress responses (brotli and gzip). Do not compress again in your app.


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
| `SMTP_TLS`           | Use TLS for the connection (`on`/`off`). Not set by default, so msmtp decides | (empty)              |

> [!TIP]
> If you don't have an SMTP server, try using a local SMTP container like [Mailpit](https://hub.docker.com/r/axllent/mailpit). With Mailpit, set `SMTP_HOST=mailpit` and `SMTP_PORT=1025` in your container.


### Debug mode

Set `DEBUG=1` to turn on verbose logging and to see which hooks run:

```shell
docker run -e DEBUG=1 shinsenter/php:8.5-fpm-nginx
```


### SSH access

Set `ENABLE_SSHD=1` and publish port 22 to log in over SSH or SFTP. Key login is the default:

```shell
docker run -p 2222:22 -e ENABLE_SSHD=1 \
    -e SSHD_AUTHORIZED_KEYS="$(cat ~/.ssh/id_ed25519.pub)" \
    shinsenter/php:8.5-fpm-nginx
ssh -p 2222 www-data@localhost
```

| Variable | Default | Effect |
|---|---|---|
| `SSHD_AUTHORIZED_KEYS` | not set | Public keys, one per line. When not empty, they replace `~/.ssh/authorized_keys` at every start |
| `SSHD_USER` | `$APP_USER` | User to log in as |
| `SSHD_PORT` | `22` | Port that sshd listens on |
| `SSHD_PASSWORD_AUTH`, `SSHD_PASSWORD` | `0`, not set | Password login stays off unless both are set |
| `SSHD_PERMIT_ROOT_LOGIN` | `0` | Allow root login |
| `SSHD_SFTP_ONLY` | `0` | Allow SFTP only, no shell |


### System settings

Environment variables for fine-tuning container behavior.

#### General

| Setting Name | Default Value | Description |
|---|---|---|
| `DEFAULT_LOG_PATH`                 | `/proc/1/fd/2`   | Where logs are written. By default, logs are sent to the container's stdout. |
| `DEBUG` or `DEBUG_MODE`            | Not set          | Enable verbose logging when set to `1`. |
| `TZ`                               | `UTC`            | Set the container's timezone. See the list of timezones. |
| `ALLOW_RUNTIME_PHP_ENVVARS`        | Not set          | Allow `$PHP_*` variables to override PHP configuration at runtime. |
| `DISABLE_GREETING`                 | Not set          | Suppress the startup greeting with `1`. |
| `SUPERVISOR_PHP_COMMAND`           | Not set          | Override the PHP command used by supervisor. Quotes group arguments that contain spaces. |


#### Project startup and autorun

| Setting Name | Default Value | Description |
|---|---|---|
| `INITIAL_PROJECT`                  | Not set          | Used only when the app directory is empty. A URL starting with `http` and ending in `.zip` or `.tar.gz` is downloaded and extracted. A URL ending in `.git` is cloned. A value like `vendor/package` is created with `composer create-project`. Any other value runs the `create-project` hook. |
| `INITIAL_PROJECT_GIT_OPTIONS`      | Not set          | Options passed to `git clone` when `INITIAL_PROJECT` is a `http*.git` URL. |
| `DISABLE_AUTORUN_SCRIPTS`          | Not set          | Set to `1` to disable autorun scripts. |
| `DISABLE_AUTORUN_CREATING_PROJECT` | Not set          | Do not create a project from `INITIAL_PROJECT` when `1`. It does not stop copying `/source/`. |
| `DISABLE_AUTORUN_COPYING_SOURCE`   | Not set          | Do not copy the files of `/source/` into the app directory when `1`. The copy runs only when the app directory is empty. |
| `DISABLE_AUTORUN_COMPOSER_INSTALL` | Not set          | Skip running `composer install` during startup when set to `1`. It does not stop `COMPOSER_OPTIMIZE_AUTOLOADER`. |
| `DISABLE_AUTORUN_GENERATING_INDEX` | Not set          | Do not generate `index.php` when set to `1`. |
| `DISABLE_AUTORUN_FIX_OWNER_GROUP`  | Not set          | When `1`, no command changes the owner of files in `APP_PATH` or `DOCUMENT_ROOT`: no ownership fix, no owner on created directories, and no UID/GID migration there. Files and directories the container creates there, such as a missing `DOCUMENT_ROOT` or `index.php`, belong to root, so set the owner of paths that `APP_USER` must write to yourself. |
| `COMPOSER_OPTIMIZE_AUTOLOADER`     | Not set          | When `1`, run `composer dumpautoload --optimize --no-cache` at startup if `composer.lock` and the `vendor` directory exist. |


#### Cron

| Setting Name | Default Value | Description |
|---|---|---|
| `ENABLE_CRONTAB`                   | Not set          | Enable Crontab service when `1`. Jobs are loaded from `$CRONTAB_DIR`. |
| `ENABLE_CRONTAB_DEBUG`             | Not set          | Adds a debug cron job that runs every minute when `1`. When set, it takes priority over `DEBUG`, so `0` removes the job even if `DEBUG=1`. |
| `CRONTAB_DIR`                      | `/etc/crontab.d` | Directory for crontab definitions. Jobs run as `$APP_USER`. |
| `CRONTAB_HOME`                     | `$APP_PATH`      | Home directory for cron jobs. |
| `CRONTAB_MAILTO`                   | Not set          | Email address to receive cron output. |
| `CRONTAB_PATH`                     | `$PATH`          | Executable search path used by cron jobs. |
| `CRONTAB_SETTINGS`                 | Not set          | Define cron jobs directly via environment variable. |
| `CRONTAB_SHELL`                    | `/bin/bash`      | Default shell for cron jobs. |
| `CRONTAB_TZ`                       | `$TZ`            | Timezone used for cron jobs. |


#### Tuning and Apache

| Setting Name | Default Value | Description |
|---|---|---|
| `ENABLE_TUNING_FPM`                | Not enabled      | Enable automatic tuning of PHP-FPM settings when set to `1`. Uses the CPU limit of the container, or the host CPU count if there is none. A `PHP_PM*` variable you pass replaces the tuned value. See [Customizing PHP-FPM](#customizing-php-fpm). |
| `ENABLE_TUNING_MPM`                | Not enabled      | Enable automatic tuning of Apache MPM settings when set to `1`. Uses the CPU and memory limits of the container, or the host values if there are none. |
| `APACHE_ALLOW_OVERRIDE`            | `all`            | Value of `AllowOverride` for the document root. `none` skips reading `.htaccess` files on every request, but rules in `.htaccess` stop working. |
| `APACHE_DEFLATE_LEVEL`             | `5`              | Compression level of `mod_deflate`, from 1 (fast) to 9 (smallest). |
| `APACHE_DISABLE_MODULES`           | Not set          | Apache modules to turn off at start, separated by spaces. |
| `APACHE_EXPIRES`                   | `access plus 1 month`| Cache lifetime that `mod_expires` sets for static file types such as CSS, JS, images and fonts. |
| `APACHE_KEEPALIVE_TIMEOUT`         | `5`              | Seconds that Apache keeps an idle connection open. |
| `APACHE_MPM_PROFILE`               | `balanced`       | Profile used by `ENABLE_TUNING_MPM`: `low`, `balanced` or `high`. |
| `APACHE_REFERRER_POLICY`           | `strict-origin-when-cross-origin` | Value of the `Referrer-Policy` response header. |
| `APACHE_REQUEST_READ_TIMEOUT`      | `header=0 body=0` (no limit) | Value of `RequestReadTimeout`. Set a limit to close connections that send the request too slowly. |


## About This Project

The platforms, stable tags, update process and security updates are in [docs/project.md](https://code.shin.company/php/blob/main/docs/project.md).


### Support the project

Keeping these images rebuilt for every PHP release takes ongoing work. If they save you time, you can help keep them going:

- ☕ [Donate via PayPal](https://www.paypal.me/shinsenter)
- 💖 [Sponsor on GitHub](https://github.com/sponsors/shinsenter)

Bug reports, fixes and docs are welcome too. See [CONTRIBUTING.md](https://code.shin.company/php/blob/main/CONTRIBUTING.md) or open an [issue](https://code.shin.company/php/issues/new).


### License

This project is licensed under the [GNU General Public License v3.0](https://code.shin.company/php/blob/main/LICENSE).

Please respect the work that went into these images. If you reuse ideas from this project, credit is appreciated.

---

From Vietnam 🇻🇳 with love.

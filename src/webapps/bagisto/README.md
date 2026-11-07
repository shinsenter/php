# shinsenter/bagisto

🛒 (PHP) Bagisto e-commerce store up and running in one command

- Docker Hub: https://hub.docker.com/r/shinsenter/bagisto
- GitHub Packages: https://code.shin.company/php/pkgs/container/bagisto
- Main documentation (all environment variables, PHP extensions, hooks, cron): [shinsenter/php](https://hub.docker.com/r/shinsenter/php)
- Other pre-built images for popular PHP apps and frameworks: https://hub.docker.com/u/shinsenter

Built on [shinsenter/laravel](https://hub.docker.com/r/shinsenter/laravel) (Nginx, PHP-FPM, Composer). For settings shared by all images, see [shinsenter/php](https://hub.docker.com/r/shinsenter/php).


## Quick start

New project: mount an empty folder. On first start the container downloads Bagisto into it (`composer create-project bagisto/bagisto`). Watch progress with `docker logs -f <container>`.

```shell
mkdir bagisto
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v ./bagisto:/var/www/html \
    shinsenter/bagisto:latest
```

Existing project: mount your code the same way. Changes on the host show up in the container at once.

Compose:

```yaml
services:
  web:
    image: shinsenter/bagisto:latest
    ports: ["80:80", "443:443", "443:443/udp"]
    volumes:
      - ./bagisto:/var/www/html
```

The image has no database. Run one as a separate service and pass its address to the app through the app's own settings.


## What is inside

| Item | Value |
|---|---|
| Base image | [shinsenter/laravel](https://hub.docker.com/r/shinsenter/laravel) |
| Web server | Nginx |
| Document root | `public` |
| New project source | `composer create-project bagisto/bagisto` |


## Laravel settings

Set these as environment variables to run extra services next to the web server.

| Variable | What it does | Default |
|---|---|---|
| `LARAVEL_AUTO_MIGRATION` | Run `artisan migrate` when the app boots. `0` turns it off. | `1` |
| `LARAVEL_AUTO_MIGRATION_OPTIONS` | Extra flags for `artisan migrate`, for example `--seed`. | not set |
| `LARAVEL_ENABLE_QUEUE_WORKER` | `1` starts a queue worker under supervisor. | `0` |
| `LARAVEL_QUEUE_WORKER_OPTIONS` | Options for the worker, for example connection or delay. | not set |
| `LARAVEL_ENABLE_SCHEDULER` | Run the Laravel scheduler. `0` turns it off. | `1` |
| `LARAVEL_SCHEDULER_OPTIONS` | Extra options for the scheduler. | not set |
| `LARAVEL_ENABLE_HORIZON` | `1` starts Laravel Horizon (queue dashboard). | `0` |
| `LARAVEL_HORIZON_OPTIONS` | Options for Horizon, for example environment or queue names. | not set |
| `LARAVEL_ENABLE_PULSE` | `1` starts Laravel Pulse (performance monitoring). | `0` |
| `LARAVEL_PULSE_OPTIONS` | Options for Pulse. | not set |
| `LARAVEL_ENABLE_REVERB` | `1` starts Laravel Reverb (WebSocket server). | `0` |
| `LARAVEL_REVERB_OPTIONS` | Options for Reverb. | not set |

> Horizon, Pulse and Reverb need their Composer packages and config in your project. The image only starts the process.


## Common settings

| Variable | What it does | Default |
|---|---|---|
| `APP_PATH` | Application directory inside the container. | `/var/www/html` |
| `DOCUMENT_ROOT` | Folder inside `APP_PATH` that the web server serves. | `public` |
| `APP_USER`, `APP_GROUP`, `APP_UID`, `APP_GID` | Run as another user and group. | `www-data` |
| `TZ` | Container timezone, for example `Asia/Tokyo`. | `UTC` |
| `DEBUG` | `1` prints verbose logs, including which hooks run. | not set |
| `ENABLE_CRONTAB`, `CRONTAB_SETTINGS` | Turn on cron and define jobs, for example `* * * * * php -f /var/www/html/cron.php`. | not set |
| `PHP_*` | Any php.ini setting, for example `PHP_MEMORY_LIMIT=512M`, `PHP_UPLOAD_MAX_FILESIZE=100M`. Run `php-envvars` in the container to list them. | image defaults |

The full list is in the [shinsenter/php](https://hub.docker.com/r/shinsenter/php) documentation.


## HTTPS

The image ships a self-signed certificate for local tests:

- `/etc/ssl/site/server.crt`
- `/etc/ssl/site/server.key`

For production, replace both files with your own, by mounting them:

```yaml
services:
  web:
    image: shinsenter/bagisto:latest
    volumes:
      - ./bagisto:/var/www/html
      - ./my_domain.crt:/etc/ssl/site/server.crt
      - ./my_domain.key:/etc/ssl/site/server.key
```

or by copying them in your own Dockerfile:

```Dockerfile
FROM shinsenter/bagisto:latest
COPY my_domain.crt /etc/ssl/site/server.crt
COPY my_domain.key /etc/ssl/site/server.key
```


## Extend the image

```Dockerfile
FROM shinsenter/bagisto:latest

# Your own steps, for example:
ADD --chown=$APP_USER:$APP_GROUP ./bagisto/ /var/www/html/
```

Adding PHP extensions, hooks, autorun scripts and cron jobs are covered in [shinsenter/php](https://hub.docker.com/r/shinsenter/php).


## Image tags and platforms

- All tags and platforms: [Docker Hub](https://hub.docker.com/r/shinsenter/bagisto/tags). Debian and Alpine variants are available.
- Since 2026-10-25, `linux/386`, `linux/arm/v7`, `linux/ppc64le` and `linux/s390x` are no longer built. Older tags keep them until they are rebuilt.
- Images are rebuilt when PHP, the base OS or Composer publish an update, so a tag can change over time. For production, pin your own copy:

```shell
docker pull shinsenter/bagisto:latest
docker tag  shinsenter/bagisto:latest your-repo/bagisto:stable
docker push your-repo/bagisto:stable
```


## Support the project

Keeping these images rebuilt for every PHP release takes ongoing work. If they save you time, you can help keep them going:

- ☕ [Donate via PayPal](https://www.paypal.me/shinsenter)
- 💖 [Sponsor on GitHub](https://github.com/sponsors/shinsenter)

Reporting a bug, sharing the project or giving it a star on [GitHub](https://code.shin.company/php) also helps.


## Issues and license

- Questions and bugs: [GitHub issues](https://code.shin.company/php/issues/new).
- Licensed under the [GNU General Public License v3.0](https://code.shin.company/php/blob/main/LICENSE). If you reuse ideas from this project, please give credit.

---

From Vietnam 🇻🇳 with love.

# shinsenter/nextcloud

☁️ (PHP) Nextcloud file server ready in one command

- Docker Hub: https://hub.docker.com/r/shinsenter/nextcloud
- GitHub Packages: https://code.shin.company/php/pkgs/container/nextcloud
- Main documentation (all environment variables, PHP extensions, hooks, cron): [shinsenter/php](https://hub.docker.com/r/shinsenter/php)
- Other pre-built images for popular PHP apps and frameworks: https://hub.docker.com/u/shinsenter

Built on [shinsenter/phpfpm-apache](https://hub.docker.com/r/shinsenter/phpfpm-apache) (Apache, PHP-FPM, Composer). For settings shared by all images, see [shinsenter/php](https://hub.docker.com/r/shinsenter/php).


## Quick start

New project: mount an empty folder. On first start the container downloads Nextcloud into it (`latest.zip` from [download.nextcloud.com](https://download.nextcloud.com/server/releases/)). Watch progress with `docker logs -f <container>`.

```shell
mkdir nextcloud
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v ./nextcloud:/var/www/html \
    shinsenter/nextcloud:latest
```

Existing project: mount your code the same way. Changes on the host show up in the container at once.

Compose:

```yaml
services:
  web:
    image: shinsenter/nextcloud:latest
    ports: ["80:80", "443:443", "443:443/udp"]
    volumes:
      - ./nextcloud:/var/www/html
```

The image has no database. Run one as a separate service and pass its address to the app through the app's own settings.


## What is inside

| Item | Value |
|---|---|
| Base image | [shinsenter/phpfpm-apache](https://hub.docker.com/r/shinsenter/phpfpm-apache) |
| Web server | Apache |
| Document root | project root |
| New project source | `latest.zip` from [download.nextcloud.com](https://download.nextcloud.com/server/releases/) |

Cron is off by default, because `cron.php` fails until Nextcloud is installed. Once it is, set `ENABLE_CRONTAB=1` to run it every 5 minutes (`CRONTAB_SETTINGS`).


## Common settings

| Variable | What it does | Default |
|---|---|---|
| `APP_PATH` | Application directory inside the container. | `/var/www/html` |
| `DOCUMENT_ROOT` | Folder inside `APP_PATH` that the web server serves. | empty (project root) |
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
    image: shinsenter/nextcloud:latest
    volumes:
      - ./nextcloud:/var/www/html
      - ./my_domain.crt:/etc/ssl/site/server.crt
      - ./my_domain.key:/etc/ssl/site/server.key
```

or by copying them in your own Dockerfile:

```Dockerfile
FROM shinsenter/nextcloud:latest
COPY my_domain.crt /etc/ssl/site/server.crt
COPY my_domain.key /etc/ssl/site/server.key
```


## Extend the image

```Dockerfile
FROM shinsenter/nextcloud:latest

# Your own steps, for example:
ADD --chown=$APP_USER:$APP_GROUP ./nextcloud/ /var/www/html/
```

Adding PHP extensions, hooks, autorun scripts and cron jobs are covered in [shinsenter/php](https://hub.docker.com/r/shinsenter/php).


## Image tags and platforms

- All tags and platforms: [Docker Hub](https://hub.docker.com/r/shinsenter/nextcloud/tags). Debian and Alpine variants are available.
- Since 2026-10-25, `linux/386`, `linux/arm/v7`, `linux/ppc64le` and `linux/s390x` are no longer built. Older tags keep them until they are rebuilt.
- Images are rebuilt when PHP, the base OS or Composer publish an update, so a tag can change over time. For production, pin your own copy:

```shell
docker pull shinsenter/nextcloud:latest
docker tag  shinsenter/nextcloud:latest your-repo/nextcloud:stable
docker push your-repo/nextcloud:stable
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

# shinsenter/frankenphp

🧟 (PHP) FrankenPHP with HTTPS built in, ready for production

- Docker Hub: https://hub.docker.com/r/shinsenter/frankenphp
- GitHub Packages: https://code.shin.company/php/pkgs/container/frankenphp
- Main documentation (all environment variables, PHP extensions, hooks, cron): [shinsenter/php](https://hub.docker.com/r/shinsenter/php)
- Other pre-built images for popular PHP apps and frameworks: https://hub.docker.com/u/shinsenter


## Quick start

```shell
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v ./myproject:/var/www/html \
    shinsenter/frankenphp:latest
```

Open http://localhost (or https://localhost with the test certificate). Your code lives in `/var/www/html`. If you mount an empty folder, the container can create a project for you: set `INITIAL_PROJECT`, for example `-e INITIAL_PROJECT=laravel/laravel`.

The images include the latest [Composer](https://getcomposer.org). PHP settings change through `PHP_*` environment variables, so you do not need to rebuild the image.

Need a specific PHP version? See the tags on [Docker Hub](https://hub.docker.com/r/shinsenter/frankenphp/tags). For a plain PHP image without FrankenPHP, see [shinsenter/php](https://hub.docker.com/r/shinsenter/php).


## Common settings

Pass them with `-e NAME=value` or in `environment:` of your compose file.

| Variable | What it does | Default |
|---|---|---|
| `APP_PATH` | Application directory inside the container. | `/var/www/html` |
| `DOCUMENT_ROOT` | Folder inside `APP_PATH` that the web server serves. | project root |
| `APP_USER`, `APP_GROUP`, `APP_UID`, `APP_GID` | Run as another user and group. | `www-data` |
| `TZ` | Container timezone, for example `Asia/Tokyo`. | `UTC` |
| `DEBUG` | `1` prints verbose logs, including which hooks run. | not set |
| `ENABLE_CRONTAB`, `CRONTAB_SETTINGS` | Turn on cron and define jobs, for example `* * * * * php -f /var/www/html/cron.php`. | not set |
| `PHP_*` | Any php.ini setting, for example `PHP_MEMORY_LIMIT=512M`, `PHP_UPLOAD_MAX_FILESIZE=100M`. Run `php-envvars` in the container to list them. | image defaults |

The full list (cron, SSH, autorun switches) is in the [shinsenter/php](https://hub.docker.com/r/shinsenter/php) documentation.


## HTTPS

The image ships a self-signed certificate for local tests:

- `/etc/ssl/site/server.crt`
- `/etc/ssl/site/server.key`

For production, replace both files with your own, by mounting them:

```yaml
services:
  web:
    image: shinsenter/frankenphp:latest
    volumes:
      - ./myproject:/var/www/html
      - ./my_domain.crt:/etc/ssl/site/server.crt
      - ./my_domain.key:/etc/ssl/site/server.key
```

or by copying them in your own Dockerfile:

```Dockerfile
FROM shinsenter/frankenphp:latest
COPY my_domain.crt /etc/ssl/site/server.crt
COPY my_domain.key /etc/ssl/site/server.key
```


## Extend the image

```Dockerfile
FROM shinsenter/frankenphp:latest

# Your own steps, for example:
ADD --chown=$APP_USER:$APP_GROUP ./myproject/ /var/www/html/
```

Adding PHP extensions, hooks, autorun scripts and cron jobs are covered in [shinsenter/php](https://hub.docker.com/r/shinsenter/php).


## Image tags and platforms

- All tags and platforms: [Docker Hub](https://hub.docker.com/r/shinsenter/frankenphp/tags). Debian and Alpine variants are available.
- Since 2026-10-25, `linux/386`, `linux/arm/v7`, `linux/ppc64le` and `linux/s390x` are no longer built. Older tags keep them until they are rebuilt.
- Images are rebuilt when PHP, the base OS or Composer publish an update, so a tag can change over time. For production, pin your own copy:

```shell
docker pull shinsenter/frankenphp:latest
docker tag  shinsenter/frankenphp:latest your-repo/frankenphp:stable
docker push your-repo/frankenphp:stable
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

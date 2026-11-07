# shinsenter/bedrock

🧱 (PHP) Bedrock, the modern WordPress stack, ready in one command

- Docker Hub: https://hub.docker.com/r/shinsenter/bedrock
- GitHub Packages: https://code.shin.company/php/pkgs/container/bedrock
- Main documentation (all environment variables, PHP extensions, hooks, cron): [shinsenter/php](https://hub.docker.com/r/shinsenter/php)
- Other pre-built images for popular PHP apps and frameworks: https://hub.docker.com/u/shinsenter

Built on [shinsenter/wordpress](https://hub.docker.com/r/shinsenter/wordpress) (Apache, PHP-FPM, Composer). For settings shared by all images, see [shinsenter/php](https://hub.docker.com/r/shinsenter/php).


## Quick start

New project: mount an empty folder. On first start the container downloads Bedrock into it (`composer create-project roots/bedrock`). Watch progress with `docker logs -f <container>`.

```shell
mkdir bedrock
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v ./bedrock:/var/www/html \
    shinsenter/bedrock:latest
```

Existing project: mount your code the same way. Changes on the host show up in the container at once.

Compose:

```yaml
services:
  web:
    image: shinsenter/bedrock:latest
    ports: ["80:80", "443:443", "443:443/udp"]
    volumes:
      - ./bedrock:/var/www/html
```

The image has no database. Run one as a separate service and pass its address to the app through the app's own settings.


## What is inside

| Item | Value |
|---|---|
| Base image | [shinsenter/wordpress](https://hub.docker.com/r/shinsenter/wordpress) |
| Web server | Apache |
| Document root | `web` |
| New project source | `composer create-project roots/bedrock` |

Defaults this image sets (you can override each with `-e`):

| Variable | Default |
|---|---|
| `ENABLE_CRONTAB` | on, unless `DISABLE_WP_CRON` is true |
| `CRONTAB_SETTINGS` | `*/5 * * * * curl http://localhost/wp/wp-cron.php` |


## WP-CLI

[WP-CLI](https://wp-cli.org) is installed as `wp`. Use it to update plugins, set up multisite and more, without a browser:

```shell
docker exec -it <container> wp plugin list
```


## Common settings

| Variable | What it does | Default |
|---|---|---|
| `APP_PATH` | Application directory inside the container. | `/var/www/html` |
| `DOCUMENT_ROOT` | Folder inside `APP_PATH` that the web server serves. | `web` |
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
    image: shinsenter/bedrock:latest
    volumes:
      - ./bedrock:/var/www/html
      - ./my_domain.crt:/etc/ssl/site/server.crt
      - ./my_domain.key:/etc/ssl/site/server.key
```

or by copying them in your own Dockerfile:

```Dockerfile
FROM shinsenter/bedrock:latest
COPY my_domain.crt /etc/ssl/site/server.crt
COPY my_domain.key /etc/ssl/site/server.key
```


## Extend the image

```Dockerfile
FROM shinsenter/bedrock:latest

# Your own steps, for example:
ADD --chown=$APP_USER:$APP_GROUP ./bedrock/ /var/www/html/
```

Adding PHP extensions, hooks, autorun scripts and cron jobs are covered in [shinsenter/php](https://hub.docker.com/r/shinsenter/php).


## Image tags and platforms

- All tags and platforms: [Docker Hub](https://hub.docker.com/r/shinsenter/bedrock/tags). Debian and Alpine variants are available.
- Since 2026-10-25, `linux/386`, `linux/arm/v7`, `linux/ppc64le` and `linux/s390x` are no longer built. Older tags keep them until they are rebuilt.
- Images are rebuilt when PHP, the base OS or Composer publish an update, so a tag can change over time. For production, pin your own copy:

```shell
docker pull shinsenter/bedrock:latest
docker tag  shinsenter/bedrock:latest your-repo/bedrock:stable
docker push your-repo/bedrock:stable
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

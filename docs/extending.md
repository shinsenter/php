<!--
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
-->

# Extending the Images

Part of the [PHP Docker Images](https://code.shin.company/php) README, moved here to keep the Docker Hub description under its 25000-byte limit.

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

> [!NOTE]
> Extensions that are already included in the official PHP images are not listed here.

> [!TIP]
> Run `docker run --rm shinsenter/php:8.5-cli php -m` (replace `8.5` as needed) to see installed extensions.


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


### Disable Autorun Scripts

To disable autorun scripts, set `DISABLE_AUTORUN_SCRIPTS=1`:

```shell
docker run -e DISABLE_AUTORUN_SCRIPTS=1 shinsenter/php:8.5-cli bash
```


## Using Cron Jobs

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

For more cron-related variables, see [System settings](https://code.shin.company/php#system-settings).

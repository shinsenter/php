# Linux Docker images with s6-overlay

🌏 Latest Linux Docker base images featuring autorun and s6-overlay.

## Introduction

Combine official [Ubuntu](http://hub.docker.com/_/ubuntu), [Debian](http://hub.docker.com/_/debian), and [Alpine Linux](http://hub.docker.com/_/alpine) Docker images with [s6-overlay](https://github.com/just-containers/s6-overlay) and an autorun mechanism. This setup simplifies the process of building portable, production-ready application containers across various architectures.

## Docker Image Variants

The Docker images are available for Debian, Ubuntu and Alpine versions.

> ℹ️ Note: We no longer maintain the `-tidy` tag names. If you are using Docker images with this tag, please replace them with the `-alpine` variant.

#### Ubuntu

- Docker Hub: https://hub.docker.com/r/shinsenter/ubuntu-s6
- GitHub Packages: https://code.shin.company/php/pkgs/container/ubuntu-s6

#### Debian

- Docker Hub: https://hub.docker.com/r/shinsenter/debian-s6
- GitHub Packages: https://code.shin.company/php/pkgs/container/debian-s6

#### Alpine

- Docker Hub: https://hub.docker.com/r/shinsenter/alpine-s6
- GitHub Packages: https://code.shin.company/php/pkgs/container/alpine-s6

## Usage

Build and try the following Dockerfile examples:

#### Ubuntu

```Dockerfile
FROM shinsenter/ubuntu-s6:latest

# Add your instructions here
# For example:
# ADD --chown=$APP_USER:$APP_GROUP ./myproject/ /var/www/html/
```

#### Debian

```Dockerfile
FROM shinsenter/debian-s6:latest

# Add your instructions here
# For example:
# ADD --chown=$APP_USER:$APP_GROUP ./myproject/ /var/www/html/
```

#### Alpine

```Dockerfile
FROM shinsenter/alpine-s6:latest

# Add your instructions here
# For example:
# ADD --chown=$APP_USER:$APP_GROUP ./myproject/ /var/www/html/
```

## Application Directory

The default application directory is `/var/www/html` and can be customized via the `$APP_PATH` environment variable:

```shell
docker run -v "$PWD":/app -e APP_PATH=/app shinsenter/ubuntu-s6:latest
```

This changes the web application directory to `/app`.

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
docker run -e APP_USER=myapp -e APP_UID=5000 shinsenter/ubuntu-s6:latest
```

Or in a `docker-compose.yml`:

```yaml
services:
  web:
    image: shinsenter/ubuntu-s6:latest
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
FROM shinsenter/ubuntu-s6:latest

ADD ./autorun/00-migration /startup/00-migration
RUN chmod +x /startup/00-migration

# Add your instructions here
# For example:
# ADD --chown=$APP_USER:$APP_GROUP ./myproject/ /var/www/html/
```

> 👉🏻 Info: The startup directory already includes a script called `99-greeting` that prints a welcome message when the container starts.

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

## Debug Mode

Enable "debug mode" for more verbose logging by setting `DEBUG=1` as an environment variable.
This can be used both with `docker run` and in `docker-compose.yml`.

#### Command Line

```shell
docker run -e DEBUG=1 shinsenter/ubuntu-s6:latest bash
```

#### docker-compose.yml

```yaml
services:
  web:
    image: shinsenter/ubuntu-s6:latest
    environment:
      DEBUG: "1"
```

## Other System Settings

These Docker images include additional environment variables for fine-tuning container behavior:

| Setting Name                       | Default Value    | Description                                                                                                                           | Example |
|------------------------------------|------------------|---------------------------------------------------------------------------------------------------------------------------------------|---------|
| `DEFAULT_LOG_PATH`                 | `/dev/stderr`    | Sets the log output path. By default, logs will be sent to the container's standard output.                                           | `/var/log/container.txt` |
| `DEBUG` or `DEBUG_MODE`            | Not set          | Activates debug mode with more verbose logs when set to "1".                                                                          | 1 |
| `TZ`                               | `UTC`            | Sets the default timezone for the container. [Full list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).               | `Asia/Tokyo` |
| `DISABLE_AUTORUN_SCRIPTS`          | Not set          | Disables all autorun scripts when set to "1".                                                                                         | 0 |
| `DISABLE_AUTORUN_FIX_OWNER_GROUP`  | Not set          | Disables automatic ownership correction of the application directory when set to "1".                                                 | 1 |
| `DISABLE_GREETING`                 | Not set          | Disables the welcome message at container startup when set to "1".                                                                    | 0 |
| `ENABLE_CRONTAB`                   | Not set          | Enables the Crontab service when set to "1", loading settings from the directory defined by `CRONTAB_DIR` (default is `/etc/crontab.d`). | 1 |
| `CRONTAB_DIR`                      | `/etc/crontab.d` | Specifies the directory containing cron job settings. Cron jobs are run as the user defined by `$APP_USER`.                           | `/path/for/crontab/schedules` |
| `CRONTAB_HOME`                     | `$APP_PATH`      | Specifies the `$HOME` directory for cron jobs.                                                                                        | `/path/for/crontab` |
| `CRONTAB_MAILTO`                   | Not set          | Email address to which cron job logs are sent.                                                                                        | `admin@example.com` |
| `CRONTAB_PATH`                     | `$PATH`          | Sets the directory paths for executing cron jobs.                                                                                     | `/path/for/crontab/bin` |
| `CRONTAB_SETTINGS`                 | Not set          | Allows you to configure cron jobs directly in the docker-compose.yml file, making it easy to manage and update scheduled tasks within your Docker container. | `0 0 * * * echo "Hello new day!"` |
| `CRONTAB_SHELL`                    | `/bin/sh`        | Sets the default shell for cron jobs.                                                                                                 | `/bin/bash` |
| `CRONTAB_TZ`                       | `$TZ`            | Sets the default timezone for cron jobs. [Full list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).                   | `Asia/Tokyo` |

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

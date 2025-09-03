# Linux Docker images with s6-overlay <!-- omit from toc -->

🌏 Latest Linux Docker base images featuring autorun and s6-overlay.


## Table of Contents <!-- omit from toc -->
- [Introduction](#introduction)
- [Docker Image Variants](#docker-image-variants)
- [Usage](#usage)
- [Application Directory](#application-directory)
- [Customizing Container User and Group in Docker](#customizing-container-user-and-group-in-docker)
- [Hooks](#hooks)
- [Autorun Scripts](#autorun-scripts)
- [Using Cron Jobs](#using-cron-jobs)
- [Debug Mode](#debug-mode)
- [Other System Settings](#other-system-settings)
- [Contributing](#contributing)
- [License](#license)


## Introduction

Combine official [Ubuntu](http://hub.docker.com/_/ubuntu), [Debian](http://hub.docker.com/_/debian), and [Alpine Linux](http://hub.docker.com/_/alpine) Docker images with [s6-overlay](https://github.com/just-containers/s6-overlay) and an autorun mechanism. This setup simplifies the process of building portable, production-ready application containers across various architectures.


## Docker Image Variants

The Docker images are available for Debian, Ubuntu and Alpine versions.

#### Ubuntu <!-- omit from toc -->

- Docker Hub: https://hub.docker.com/r/shinsenter/ubuntu-s6
- GitHub Packages: https://code.shin.company/php/pkgs/container/ubuntu-s6

#### Debian <!-- omit from toc -->

- Docker Hub: https://hub.docker.com/r/shinsenter/debian-s6
- GitHub Packages: https://code.shin.company/php/pkgs/container/debian-s6

#### Alpine <!-- omit from toc -->

- Docker Hub: https://hub.docker.com/r/shinsenter/alpine-s6
- GitHub Packages: https://code.shin.company/php/pkgs/container/alpine-s6


## Usage

Build and try the following Dockerfile examples:

#### Ubuntu <!-- omit from toc -->

```Dockerfile
FROM shinsenter/ubuntu-s6:latest

# Add your instructions here
# For example:
# ADD --chown=$APP_USER:$APP_GROUP ./myproject/ /var/www/html/
```

#### Debian <!-- omit from toc -->

```Dockerfile
FROM shinsenter/debian-s6:latest

# Add your instructions here
# For example:
# ADD --chown=$APP_USER:$APP_GROUP ./myproject/ /var/www/html/
```

#### Alpine <!-- omit from toc -->

```Dockerfile
FROM shinsenter/alpine-s6:latest

# Add your instructions here
# For example:
# ADD --chown=$APP_USER:$APP_GROUP ./myproject/ /var/www/html/
```


## Application Directory

The default application directory is `/var/www/html` and can be customized via the `$APP_PATH` environment variable:

```shell
docker run -v "$PWD":/app -e APP_PATH=/app shinsenter/debian-s6:latest
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
docker run -e APP_USER=myapp -e APP_UID=5000 shinsenter/debian-s6:latest
```

Or in a `docker-compose.yml`:

```yaml
services:
  web:
    image: shinsenter/debian-s6:latest
    environment:
      APP_USER: "myapp"
      APP_UID: "5000"
```


## Hooks

Hooks are useful for customizing the behavior of a running container.<br/>
These images support the following hooks:

| Hook name   | Description                                          | Example usage              |
|-------------|------------------------------------------------------|----------------------------|
| `onboot`    | Runs when the container starts or restarts.          | Send startup notification. |
| `first-run` | Runs only the first time the container starts.       | Initialize database.       |
| `rebooted`  | Runs whenever the container restarts.                | Check crash logs.          |
| `migration` | Runs migration scripts.                              | Run DB migrations.         |
| `onready`   | Runs after `migration`, when the app is nearly ready.| Warm up caches.            |

To use hooks, create a `hooks` folder inside `$APP_PATH` and add executable files named after the hook, or in subfolders with the same name.
Example: to install PHP modules at `first-run`, add a script `hooks/first-run` or `hooks/first-run/install-modules`.

Set `DEBUG=1` to see which hooks are executed.


## Autorun Scripts

Shell scripts placed in the `/startup/` directory will automatically run when the container starts, in alphabetical order by filename.
This feature can initialize projects before the main program runs, saving time by executing initialization scripts automatically.

#### Usage Example <!-- omit from toc -->

Copy a script called `00-migration` into `/startup/` via a Dockerfile:

> Note: Ensure the script has executable permissions.

```Dockerfile
FROM shinsenter/debian-s6:latest

ADD ./autorun/00-migration /startup/00-migration
RUN chmod +x /startup/00-migration

# Add your instructions here
# For example:
# ADD --chown=$APP_USER:$APP_GROUP ./myproject/ /var/www/html/
```

> 👉🏻 Info: The startup directory already includes a script called `99-greeting` that prints a welcome message when the container starts.

#### Disable Autorun Scripts <!-- omit from toc -->

To disable autorun scripts, set `DISABLE_AUTORUN_SCRIPTS=1` as an environment variable.

For example, with `docker run`:

```shell
docker run -e DISABLE_AUTORUN_SCRIPTS=1 shinsenter/debian-s6:latest bash
```

Or in `docker-compose.yml`:

```yaml
services:
  web:
    image: shinsenter/debian-s6:latest
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
FROM shinsenter/debian-s6:latest

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
    image: shinsenter/debian-s6:latest
    environment:
      ENABLE_CRONTAB: "1"
      CRONTAB_SETTINGS: "* * * * * echo 'This line will run every minute!' | tee /tmp/cron-every-minute.txt"
```

For more information on environment variables for cron jobs, refer to the [Other System Settings](#other-system-settings) section below.


## Debug Mode

Enable "debug mode" for more verbose logging by setting `DEBUG=1` as an environment variable.
This can be used both with `docker run` and in `docker-compose.yml`.

#### Command Line <!-- omit from toc -->

```shell
docker run -e DEBUG=1 shinsenter/debian-s6:latest bash
```

#### docker-compose.yml <!-- omit from toc -->

```yaml
services:
  web:
    image: shinsenter/debian-s6:latest
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
| `DISABLE_AUTORUN_SCRIPTS`          | Not set          | Disables all autorun scripts when set to `1`. | `1` |
| `DISABLE_AUTORUN_FIX_OWNER_GROUP`  | Not set          | Disables automatic correction of ownership for the application directory when set to `1`. | `1` |
| `DISABLE_GREETING`                 | Not set          | Suppresses the startup greeting message when set to `1`. | `1` |
| `ENABLE_SSHD`                      | Not set          | When set to `1`, enable the SSH server inside the container. | `1` |
| `SSHD_AUTHORIZED_KEYS`             | Not set          | Public SSH keys (one per line) that will be added to the container's `~/.ssh/authorized_keys` for authentication. | `ssh-rsa XXXX...` |
| `ENABLE_CRONTAB`                   | Not set          | Enables the Crontab service when set to `1`, loading job definitions from `$CRONTAB_DIR` (default: `/etc/crontab.d`). | `1` |
| `ENABLE_CRONTAB_DEBUG`             | Not set          | When set to `1`, adds a debug cron job that runs every minute and prints environment variables visible to cron. | `1` |
| `CRONTAB_DIR`                      | `/etc/crontab.d` | Directory where cron job definitions are located. Jobs run as the user specified in `$APP_USER`. | `/path/for/crontab/schedules` |
| `CRONTAB_HOME`                     | `$APP_PATH`      | Sets the `$HOME` directory used during cron job execution. | `/path/for/crontab` |
| `CRONTAB_MAILTO`                   | Not set          | Email address to receive cron job output. | `admin@example.com` |
| `CRONTAB_PATH`                     | `$PATH`          | Defines the executable search path used by cron jobs. | `/path/for/crontab/bin` |
| `CRONTAB_SETTINGS`                 | Not set          | Allows defining cron jobs directly in `docker-compose.yml`, making it easy to manage scheduled tasks inside the container. | `0 0 * * * echo "Hello new day!"` |
| `CRONTAB_SHELL`                    | `/bin/sh`        | Specifies the default shell used for cron job execution. | `/bin/bash` |
| `CRONTAB_TZ`                       | `$TZ`            | Sets the timezone for cron jobs. See the [full list of timezones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones). | `Asia/Tokyo` |
| `SUPERVISOR_PHP_COMMAND`           | Not set          | Overrides the container’s default entrypoint with a custom PHP command to serve the application.  | `php -S localhost:80 index.php` |


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

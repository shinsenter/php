# Linux Docker images with s6-overlay

🌏 Latest Linux Docker base images including autorun and s6-overlay.

## Introduction

The combination of official [Ubuntu](http://hub.docker.com/_/ubuntu)/[Debian](http://hub.docker.com/_/debian)/[Alpine Linux](http://hub.docker.com/_/alpine) Docker images, [s6-overlay](https://github.com/just-containers/s6-overlay), and autorun mechanism, that simplifies building portable, production-ready application containers across architectures.

## Docker Image Variants

#### Ubuntu

- Docker Hub: https://hub.docker.com/r/shinsenter/ubuntu-s6
- GitHub Packages: https://github.com/shinsenter/php/pkgs/container/ubuntu-s6

#### Debian

- Docker Hub: https://hub.docker.com/r/shinsenter/debian-s6
- GitHub Packages: https://github.com/shinsenter/php/pkgs/container/debian-s6

#### Alpine

- Docker Hub: https://hub.docker.com/r/shinsenter/alpine-s6
- GitHub Packages: https://github.com/shinsenter/php/pkgs/container/alpine-s6

## Usage

Build the following Dockerfile and try it out:

#### Ubuntu

```Dockerfile
FROM shinsenter/ubuntu-s6:latest

# You may add your constructions from here
# For example:
# ADD --chown=$APP_USER:$APP_GROUP ./myproject/ /var/www/html/
```

#### Debian

```Dockerfile
FROM shinsenter/debian-s6:latest

# You may add your constructions from here
# For example:
# ADD --chown=$APP_USER:$APP_GROUP ./myproject/ /var/www/html/
```

#### Alpine

```Dockerfile
FROM shinsenter/alpine-s6:latest

# You may add your constructions from here
# For example:
# ADD --chown=$APP_USER:$APP_GROUP ./myproject/ /var/www/html/
```

## Application Directory

The default application directory is `/var/www/html` and can be customized via the `$APP_PATH` environment variable:

```shell
docker run -v "$PWD":/app \
    -e APP_PATH=/app \
    shinsenter/ubuntu-s6:latest
```

This would change the web application directory to `/app`.

## Customize Container User and Group in Docker

The Docker image likely has a default user and group set, such as `www-data` for a web server image. However, you can override these defaults by setting environment variables when running the container.

The available variables are:

| Environment Variable | Description                             | Default          |
|----------------------|-----------------------------------------|------------------|
| `APP_USER`           | Sets the username inside the container  | `www-data`       |
| `APP_GROUP`          | Sets the groupname inside the container | `www-data`       |
| `APP_UID`            | Sets the numeric uid of the user        | uid in container |
| `APP_GID`            | Sets the numeric gid of the group       | gid in container |


For example, to run a container as user `myapp` with uid `5000`, you could do:
```shell
docker run \
    -e APP_USER=myapp \
    -e APP_UID=5000 \
    shinsenter/ubuntu-s6:latest
```

Or in a `docker-compose.yml`:
```yaml
services:
  web:
    image: shinsenter/ubuntu-s6:latest
    environment:
      - APP_USER=myapp
      - APP_UID=5000
```

## Autorun Scripts

Shell scripts copied into the `/startup/` directory of container will automatically run when container starts, in alphabetical order by filename.

This mechanism can be used to initialize projects before the main program on the container runs. The autorun saves time by executing initialization scripts without manual intervention.

#### Usage

For example, a script called `00-migration` could be copied into `/startup/` via a Dockerfile.

> Note: The script file must have executable permissions to run.

```Dockerfile
FROM shinsenter/ubuntu-s6:latest

ADD ./autorun/00-migration /startup/00-migration
RUN chmod +x /startup/00-migration
```

> 👉🏻 Info: The startup directory already includes a script called `99-greeting` that prints a welcome message when container starts.

#### Disable autorun scripts

To disable autorunning scripts, set `DISABLE_AUTORUN_SCRIPTS=1` as an environment variable.

For example, this can be done with docker run:
```shell
docker run -e DISABLE_AUTORUN_SCRIPTS=1 shinsenter/ubuntu-s6:latest bash
```

Or in a `docker-compose.yml`:
```yaml
services:
  web:
    image: shinsenter/ubuntu-s6:latest
    environment:
      - DISABLE_AUTORUN_SCRIPTS=1
```

## Debug mode

Sometimes you may need a "debug mode" for more verbose logging.

You can pass `DEBUG=1` as an environment variable to the container for more verbose logging. The application can check for this and enable debug mode, outputting more logs.

This works both with `docker run` and in `docker-compose.yml`.

#### Command Line

```shell
docker run -e DEBUG=1 shinsenter/ubuntu-s6:latest bash
```

#### docker-compose.yml

```yml
services:
  web:
    image: shinsenter/ubuntu-s6:latest
    environment:
      - DEBUG=1
```

## Other System Settings

These Docker images also include other environment variables for fine-tuning the behavior of the container.

| Setting Name                       | Default Value | Description                                                      | Example |
|------------------------------------|---------------|------------------------------------------------------------------|---------|
| `DEBUG` or `DEBUG_MODE`            | Not set       | When set to "1", this enables debug mode with more verbose logs. | 1 |
| `DISABLE_AUTORUN_SCRIPTS`          | Not set       | When set to "1", this disables all autorun scripts.              | 0 |
| `DISABLE_GREETING`                 | Not set       | When set to "1", this disables showing the welcome message when the container starts. | 0 |
| `ENABLE_CRONTAB`                   | Not enabled   | When set to "1", this enables the crontab service. When crontab is enabled, it loads settings in the directory defined by the `CRONTAB_DIR` environment variable (default is /etc/crontab.d). | 1 |
| `FIX_APP_PATH_PERMISSION`          | Not set       | When set to "1", this corrects the ownership of the app directory. | 1 |

## Contributing

If you find these images useful, consider donating via [PayPal](https://www.paypal.me/shinsenter)
or opening an issue on [GitHub](https://github.com/shinsenter/php/issues/new).

Your support helps keep these images maintained and improved for the community.

## License

This project is licensed under the terms of the [GNU General Public License v3.0](https://code.shin.company/php/blob/main/LICENSE).

I appreciate you respecting my intellectual efforts in creating them.
If you intend to copy or use ideas from this project, please credit properly.

---

From Vietnam 🇻🇳 with love.

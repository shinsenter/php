# shinsenter/hypervel

🔋 (PHP / Hypervel) Production-ready Docker images with automatic Hypervel installer.

- Docker Hub: https://hub.docker.com/r/shinsenter/hypervel
- GitHub Packages: https://code.shin.company/php/pkgs/container/hypervel
- You can also find and use [other pre-built Docker images for some popular PHP applications and frameworks here](https://hub.docker.com/u/shinsenter).
- Main documentation: [shinsenter/php](https://code.shin.company/php)

The Docker images are available for both Debian and Alpine versions.


## Introduction

Our PHP Docker images, available on [Docker Hub](https://hub.docker.com/r/shinsenter/php),
let you configure PHP and PHP-FPM settings through environment variables, with no image rebuild required.

These images also include the latest version of [Composer](https://getcomposer.org).


## Usage

[![shinsenter/php](https://repository-images.githubusercontent.com/458053748/5a05c8e4-1c00-440c-98f1-2cd4548bbaa2)](https://docker.shin.company/php)

Check out [our documentation](https://hub.docker.com/r/shinsenter/php) to learn how to customize these Docker images for your projects.


## Creating a New Project

When you mount an empty directory into the container, it will automatically download the entire source code for the framework, allowing you to bootstrap a new project quickly.

### Steps to Create a New Project

1. Create an empty directory on your host machine for your project code. For example:

```shell
mkdir hypervel
```

2. Run the container and mount the empty directory as a volume. For example:

```shell
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v ./hypervel:/var/www/html \
    shinsenter/hypervel:latest
```

The container will detect the empty directory mounted to `/var/www/html` and clone the framework source code into it.


## Using an Existing Project

You can mount your application code from your host machine to the `/var/www/html` directory inside the container.

Because the source code is mounted as a volume, any changes made on the host machine are reflected inside the container.


## Using HTTPS

The Docker images come with pre-generated SSL certificate files for testing HTTPS locally:

- /etc/ssl/site/server.crt
- /etc/ssl/site/server.key

To use valid HTTPS certificates in production, replace these files with your own certificate and key.
Copy or mount your certificates from the host machine into the container, overwriting the default files.

#### Using Dockerfile

```Dockerfile
FROM shinsenter/hypervel:latest

# Copy your own certs into the container
COPY my_domain.crt /etc/ssl/site/server.crt
COPY my_domain.key /etc/ssl/site/server.key

# Add your instructions here
# For example:
# ADD --chown=$APP_USER:$APP_GROUP ./hypervel/ /var/www/html/
```

#### Using docker run

```shell
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v ./hypervel:/var/www/html \
    -v ./my_domain.crt:/etc/ssl/site/server.crt \
    -v ./my_domain.key:/etc/ssl/site/server.key \
    shinsenter/hypervel:latest
```

#### Using docker-compose

```yml
services:
  web:
    image: shinsenter/hypervel:latest
    volumes:
      - ./hypervel:/var/www/html
      - ./my_domain.crt:/etc/ssl/site/server.crt
      - ./my_domain.key:/etc/ssl/site/server.key
```


## Environment variables

You can optionally set the following environment variables in the container to enable certain services to run alongside the web server.

| Environment Variable             | Description             |
|----------------------------------|-------------------------|
| `LARAVEL_AUTO_MIGRATION`         | Whether to automatically run database migrations when the app boots. Set to `0` to disable running migration. **Default is `1`**. |
| `LARAVEL_AUTO_MIGRATION_OPTIONS` | Additional options/flags to pass to the `artisan migrate` command (e.g. `--seed`). |
| `LARAVEL_ENABLE_QUEUE_WORKER`    | Enables supervisor service for the Laravel queue worker. Set to `1` to start processing jobs. **Default is `0`**. |
| `LARAVEL_QUEUE_WORKER_OPTIONS`   | Defines custom options for the Laravel queue worker (e.g., connection, delay). |


## Stable Image Tags

The release versions on [this GitHub repository](https://code.shin.company/php) don't guarantee
that Docker images built from the same source code will always be identical.

We build new Docker images daily to ensure they stay up-to-date
with the latest upstream updates for PHP, base OS, Composer, etc.
The images in this repo are regularly updated under the same tag names.

But you can pull the image from `shinsenter/hypervel:latest`,
and tag it with a name that indicates its stability,
such as `your-repo/hypervel:stable` using the below commands:

```shell
docker pull shinsenter/hypervel:latest
docker tag  shinsenter/hypervel:latest your-repo/hypervel:stable
docker push your-repo/hypervel:stable
```

Then use the image `your-repo/hypervel:stable` as a base image to build containers for production.


## Contributing

If you find these images useful, consider donating via [PayPal](https://www.paypal.me/shinsenter) or opening an issue on [GitHub](https://code.shin.company/php/issues/new).


## License

This project is licensed under the terms of the [GNU General Public License v3.0](https://code.shin.company/php/blob/main/LICENSE).

Please respect the work that went into these images. If you reuse ideas from this project, credit is appreciated.

---

From Vietnam 🇻🇳 with love.

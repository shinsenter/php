# shinsenter/statamic

🔋 (PHP / Statamic) Production-ready Docker images with automatic Statamic installer.

- Docker Hub: https://hub.docker.com/r/shinsenter/statamic
- GitHub Packages: https://code.shin.company/php/pkgs/container/statamic
- You can also find and use [other pre-built Docker images for some popular PHP applications and frameworks here](https://hub.docker.com/u/shinsenter).

The Docker images are available for both Debian and Alpine versions.


## Introduction

Our PHP Docker images, available on [Docker Hub](https://hub.docker.com/r/shinsenter/php),
are designed for easy configuration of PHP and PHP-FPM settings via environment variables.
This approach eliminates the need to rebuild images when making configuration changes.

These images also come with the latest version of [Composer](https://getcomposer.org),
enabling you to start projects quickly without additional installations.


## Usage

[![shinsenter/php](https://repository-images.githubusercontent.com/458053748/5a05c8e4-1c00-440c-98f1-2cd4548bbaa2)](https://docker.shin.company/php)

Check out [our documentation](https://hub.docker.com/r/shinsenter/php) to learn how to customize these Docker images for your projects.


## Creating a New Project

When you mount an empty directory into the container, it will automatically download the entire source code for the framework, allowing you to bootstrap a new project quickly.

### Steps to Create a New Project

1. Create an empty directory on your host machine for your project code. For example:

```shell
mkdir statamic
```

2. Run the container and mount the empty directory as a volume. For example:

```shell
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v ./statamic:/var/www/html \
    shinsenter/statamic:latest
```

The container will detect the empty directory mounted to `/var/www/html` and clone the framework source code into it.


## Using an Existing Project

You can mount your application code from your host machine to the `/var/www/html` directory inside the container.

Because the source code is mounted as a volume,
any changes made on the host machine will be reflected inside the container.
This setup allows you to run builds, tests,
and other tasks within the container while keeping your code on the host.


## Using HTTPS

The Docker images come with pre-generated SSL certificate files for testing HTTPS locally:

- /etc/ssl/site/server.crt
- /etc/ssl/site/server.key

To use valid HTTPS certificates for your production website,
replace these files with your own valid SSL certificates.
You can do this by copying or mounting your certificates from the host machine into the container.
Simply overwrite the default certificate files with your valid certificate and key files
to enable true HTTPS for your production website.

#### Using Dockerfile

```Dockerfile
FROM shinsenter/statamic:latest

# Copy your own certs into the container
COPY my_domain.crt /etc/ssl/site/server.crt
COPY my_domain.key /etc/ssl/site/server.key

# Add your instructions here
# For example:
# ADD --chown=$APP_USER:$APP_GROUP ./statamic/ /var/www/html/
```

#### Using docker run

```shell
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v ./statamic:/var/www/html \
    -v ./my_domain.crt:/etc/ssl/site/server.crt \
    -v ./my_domain.key:/etc/ssl/site/server.key \
    shinsenter/statamic:latest
```

#### Using docker-compose

```yml
services:
  web:
    image: shinsenter/statamic:latest
    volumes:
      - ./statamic:/var/www/html
      - ./my_domain.crt:/etc/ssl/site/server.crt
      - ./my_domain.key:/etc/ssl/site/server.key
```


## Environment variables

You can optionally set the following environment variables in the container to enable certain services to run alongside the web server.

> 📝 Note: you'll need to install the required packages and create the necessary configs yourself for features like Pulse or Statamic Horizon.

| Environment Variable             | Description             |
|----------------------------------|-------------------------|
| `LARAVEL_AUTO_MIGRATION`         | Whether to automatically run database migrations when the app boots. Set to `0` to disable running migration. **Default is `1`**. |
| `LARAVEL_AUTO_MIGRATION_OPTIONS` | Additional options/flags to pass to the `artisan migrate` command. |
| `LARAVEL_ENABLE_QUEUE_WORKER`    | Enables supervisor service for the Laravel queue worker. Set to `1` to start processing jobs. **Default is `0`**. |
| `LARAVEL_QUEUE_WORKER_OPTIONS`   | Defines custom options for the Laravel queue worker (e.g., connection, delay). |
| `LARAVEL_ENABLE_SCHEDULER`       | Enables supervisor service for the Laravel scheduler. Set to `0` to disable running scheduled tasks. **Default is `1`**. |
| `LARAVEL_SCHEDULER_OPTIONS`      | Specifies additional options for the scheduler execution. |
| `LARAVEL_ENABLE_HORIZON`         | Enables supervisor service for Laravel Horizon, a dashboard for managing queues. **Default is `0`**. |
| `LARAVEL_HORIZON_OPTIONS`        | Options for customizing Horizon behavior (e.g., environment, queue names). |
| `LARAVEL_ENABLE_PULSE`           | Enables supervisor service for Laravel Pulse for application performance monitoring. **Default is `0`**. |
| `LARAVEL_PULSE_OPTIONS`          | Configuration options for Laravel Pulse (e.g., port, storage). |
| `LARAVEL_ENABLE_REVERB`          | Enables supervisor service for Laravel Reverb for real-time WebSocket communication. **Default is `0`**. |
| `LARAVEL_REVERB_OPTIONS`         | Configuration options for Laravel Reverb (e.g., port, storage). |


## Stable Image Tags

The release versions on [this GitHub repository](https://code.shin.company/php) don't guarantee
that Docker images built from the same source code will always be identical.

We build new Docker images daily to ensure they stay up-to-date
with the latest upstream updates for PHP, base OS, Composer, etc.
The images in this repo are regularly updated under the same tag names.

But you can pull the image from `shinsenter/statamic:latest`,
and tag it with a name that indicates its stability,
such as `your-repo/statamic:stable` using the below commands:

```shell
docker pull shinsenter/statamic:latest
docker tag  shinsenter/statamic:latest your-repo/statamic:stable
docker push your-repo/statamic:stable
```

Then use the image `your-repo/statamic:stable` as a base image to build containers for production.


## Contributing

If you find these images useful, consider donating via [PayPal](https://www.paypal.me/shinsenter) or opening an issue on [GitHub](https://code.shin.company/php/issues/new).

Your support helps maintain and improve these images for the community.


## License

This project is licensed under the terms of the [GNU General Public License v3.0](https://code.shin.company/php/blob/main/LICENSE).

Thank you for recognizing the intellectual effort behind this project. If you plan to use or build upon any of its ideas, I kindly ask that you give appropriate credit.

---

From Vietnam 🇻🇳 with love.

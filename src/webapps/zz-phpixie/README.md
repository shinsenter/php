# shinsenter/phpixie

🔋 (PHP / PHPixie) Production-ready Docker images with automatic PHPixie installer.

- Docker Hub: https://hub.docker.com/r/shinsenter/phpixie
- GitHub Packages: https://code.shin.company/php/pkgs/container/phpixie

The Docker images are available for both Debian and Alpine versions.

<!-- > ℹ️ Note: We no longer maintain the `-tidy` tag names. If you are using Docker images with this tag, please replace them with the `-alpine` variant. -->

> <font color="orange">ℹ️ Note: These Docker images won’t be updated anymore since it looks like the framework hasn't been active in a long time.
> You can still use the old Docker images. If you hear about any updates to the framework, please let us know.</font>

## Introduction

Our PHP Docker images, available on [Docker Hub](https://hub.docker.com/r/shinsenter/php),
are designed for easy configuration of PHP and PHP-FPM settings via environment variables.
This approach eliminates the need to rebuild images when making configuration changes.

These images also come with the latest version of [Composer](https://getcomposer.org),
enabling you to start projects quickly without additional installations.

## Usage

[![shinsenter/php](https://repository-images.githubusercontent.com/458053748/24e848e1-c0fc-4893-b2b9-f7dbfad263f3)](https://docker.shin.company/php)

Check out [our documentation](https://hub.docker.com/r/shinsenter/php) to learn how to customize these Docker images for your projects.

## Creating a New Project

When you mount an empty directory into the container, it will automatically download the entire source code for the framework, allowing you to bootstrap a new project quickly.

### Steps to Create a New Project

1. Create an empty directory on your host machine for your project code. For example:

```shell
mkdir myproject
```

2. Run the container and mount the empty directory as a volume. For example:

```shell
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v ./myproject:/var/www/html \
    shinsenter/phpixie:latest
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
FROM shinsenter/phpixie:latest

# Copy your own certs into the container
COPY my_domain.crt /etc/ssl/site/server.crt
COPY my_domain.key /etc/ssl/site/server.key

# Add your instructions here
# For example:
# ADD --chown=$APP_USER:$APP_GROUP ./myproject/ /var/www/html/
```

#### Using docker run

```shell
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v ./myproject:/var/www/html \
    -v ./my_domain.crt:/etc/ssl/site/server.crt \
    -v ./my_domain.key:/etc/ssl/site/server.key \
    shinsenter/phpixie:latest
```

#### Using docker-compose

```yml
services:
  web:
    image: shinsenter/phpixie:latest
    volumes:
      - ./myproject:/var/www/html
      - ./my_domain.crt:/etc/ssl/site/server.crt
      - ./my_domain.key:/etc/ssl/site/server.key
```

## Stable Image Tags

The release versions on [this GitHub repository](https://code.shin.company/php) don't guarantee
that Docker images built from the same source code will always be identical.

We build new Docker images daily to ensure they stay up-to-date
with the latest upstream updates for PHP, base OS, Composer, etc.
The images in this repo are regularly updated under the same tag names.

But you can pull the image from `shinsenter/phpixie:latest`,
and tag it with a name that indicates its stability,
such as `your-repo/phpixie:stable` using the below commands:

```shell
docker pull shinsenter/phpixie:latest
docker tag  shinsenter/phpixie:latest your-repo/phpixie:stable
docker push your-repo/phpixie:stable
```

Then use the image `your-repo/phpixie:stable` as a base image to build containers for production.

## Contributing

If you find these images useful, consider donating via [PayPal](https://www.paypal.me/shinsenter) or opening an issue on [GitHub](https://code.shin.company/php/issues/new).

Your support helps maintain and improve these images for the community.

## License

This project is licensed under the terms of the [GNU General Public License v3.0](https://code.shin.company/php/blob/main/LICENSE).

I appreciate you respecting my intellectual efforts in creating them. If you intend to copy or use ideas from this project, please give proper credit.

---

From Vietnam 🇻🇳 with love.

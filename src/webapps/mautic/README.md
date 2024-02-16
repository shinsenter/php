# shinsenter/mautic

🌏 (PHP) Mautic docker containers for both production and development.

> Docker Hub: https://hub.docker.com/r/shinsenter/mautic

## Introduction

Built on top of [our PHP Docker images](https://hub.docker.com/r/shinsenter/php), these images enable easy tuning of PHP and PHP-FPM settings through environment variables. This eliminates the need to rebuild images when changing settings.

These images also include the latest version of [Composer](https://getcomposer.org), allowing projects to get started faster without additional installation.

## Usage

[![shinsenter/php](https://repository-images.githubusercontent.com/458053748/24e848e1-c0fc-4893-b2b9-f7dbfad263f3)](https://docker.shin.company/php)

Refer to [our documentation](https://hub.docker.com/r/shinsenter/php) to learn how to customize these Docker images for your projects.

## Create new project

When you mount an empty directory into the container, it will automatically pull down the entire source code for the framework. This allows you to quickly bootstrap a new project.

### To do this

Create an empty directory on your host machine that will be used for your project code. For example:

```shell
mkdir myproject
```

When running the container, mount this empty directory as a volume. For example:

```shell
docker run --rm -p 80:80 -p 443:443 \
    -v ./myproject:/var/www/html \
    shinsenter/mautic:latest
```

The container will detect content in directory mounted to `/var/www/html` and clone the framework source code into it if it is empty.

## Existing project

You can mount your application code on your host machine to `/var/www/html` directory inside the container.

Because the source code is mounted as a volume, your changes on the host will be reflected in the container. You can run builds, tests, etc inside the container and see the changes.

This allows you to leverage the container while keeping your code on the host.

## Using HTTPS

The Docker images come with pre-generated SSL certificate files for testing HTTPS websites locally.

The files are:
- /etc/ssl/site/server.crt
- /etc/ssl/site/server.key

To use valid HTTPS certificates for your website in production, you need to replace these files with your own valid SSL certificates by copying over or mounting from the host machine into the container. Simply overwrite the default certificate files with your own valid cert and key files to enable true HTTPS for your production website.

#### Using Dockerfile

```Dockerfile
FROM shinsenter/mautic:latest

# Copy your own certs into the container
COPY my_site.crt /etc/ssl/site/server.crt
COPY my_site.key /etc/ssl/site/server.key
```

#### Using docker run

```shell
docker run --rm -p 80:80 -p 443:443 \
    -v ./myproject:/var/www/html \
    -v ./my_site.crt:/etc/ssl/site/server.crt \
    -v ./my_site.key:/etc/ssl/site/server.key \
    shinsenter/mautic:latest
```

#### Using docker-compose:

```yml
services:
  web:
    image: shinsenter/mautic:latest
    volumes:
      - ./my_site.crt:/etc/ssl/site/server.crt
      - ./my_site.key:/etc/ssl/site/server.key
```

## Contributing

If you find these images useful, consider donating via [PayPal](https://www.paypal.me/shinsenter) or open an issue on [Github](https://github.com/shinsenter/php/issues/new).

Your support helps keep these images maintained and improved for the community.

## License

This project is licensed under the terms of the [GNU General Public License v3.0](https://code.shin.company/php/blob/main/LICENSE).

I appreciate you respecting my intellectual efforts in creating them. If you intend to copy or use ideas from this project, please credit properly.

---

From Vietnam 🇻🇳 with love.

# shinsenter/unit-php

🌏 (PHP) PHP + Nginx Unit docker containers for both production and development.

- Docker Hub: https://hub.docker.com/r/shinsenter/unit-php
- GitHub Packages: https://github.com/shinsenter/php/pkgs/container/unit-php

## Introduction

Our PHP Docker images, available on [Docker Hub](https://hub.docker.com/r/shinsenter/php),
are designed for easy configuration of PHP and PHP-FPM settings via environment variables.
This approach eliminates the need to rebuild images when making configuration changes.

These images also come with the latest version of [Composer](https://getcomposer.org),
enabling you to start projects quickly without additional installations.

## Usage

```shell
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v ./myproject:/var/www/html \
    shinsenter/unit-php:latest
```

[![shinsenter/php](https://repository-images.githubusercontent.com/458053748/24e848e1-c0fc-4893-b2b9-f7dbfad263f3)](https://docker.shin.company/php)

Refer to [our documentation](https://hub.docker.com/r/shinsenter/php) to learn how to customize these Docker images for your projects.

## Using HTTPS

The Docker images come with pre-generated SSL certificate files for testing HTTPS websites locally.

The files are:
- /etc/ssl/site/server.crt
- /etc/ssl/site/server.key

To use valid HTTPS certificates for your production website,
you need to replace these files with your own valid SSL certificates
by copying or mounting them from the host machine into the container.
Simply overwrite the default certificate files with your own valid
certificate and key files to enable true HTTPS for your production website.

#### Using Dockerfile

```Dockerfile
FROM shinsenter/unit-php:latest

# Copy your own certs into the container
COPY my_domain.crt /etc/ssl/site/server.crt
COPY my_domain.key /etc/ssl/site/server.key
```

#### Using docker run

```shell
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v ./myproject:/var/www/html \
    -v ./my_domain.crt:/etc/ssl/site/server.crt \
    -v ./my_domain.key:/etc/ssl/site/server.key \
    shinsenter/unit-php:latest
```

#### Using docker-compose

```yml
services:
  web:
    image: shinsenter/unit-php:latest
    volumes:
      - ./myproject:/var/www/html
      - ./my_domain.crt:/etc/ssl/site/server.crt
      - ./my_domain.key:/etc/ssl/site/server.key
```

## Supported Platforms

Check our [Docker Hub](https://hub.docker.com/r/shinsenter/unit-php/tags) for all available platforms.

> Docker image tags ending in `-alpine` or `-tidy` indicate Docker images built on the Alpine Linux base operating system.
> These Docker images are lightweight, helping to speed up builds and save bandwidth for your CI/CD pipelines.

## Contributing

If you find these images useful, consider donating via [PayPal](https://www.paypal.me/shinsenter)
or opening an issue on [GitHub](https://github.com/shinsenter/php/issues/new).

Your support helps maintain and improve these images for the community.

## License

This project is licensed under the terms of the [GNU General Public License v3.0](https://code.shin.company/php/blob/main/LICENSE).

Please respect the intellectual efforts involved in creating these images.
If you intend to copy or use ideas from this project, proper credit is appreciated.

---

From Vietnam 🇻🇳 with love.

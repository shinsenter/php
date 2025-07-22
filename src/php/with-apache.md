# shinsenter/phpfpm-apache

🌏 (PHP) PHP-FPM + Apache2 Docker images for both production and development.

- Docker Hub: https://hub.docker.com/r/shinsenter/phpfpm-apache
- GitHub Packages: https://code.shin.company/php/pkgs/container/phpfpm-apache
- You can also find and use [other pre-built Docker images for some popular PHP applications and frameworks here](https://hub.docker.com/u/shinsenter).


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
    shinsenter/phpfpm-apache:latest
```

[![shinsenter/php](https://repository-images.githubusercontent.com/458053748/5a05c8e4-1c00-440c-98f1-2cd4548bbaa2)](https://docker.shin.company/php)

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
FROM shinsenter/phpfpm-apache:latest

# Copy your own certificates into the container
COPY my_domain.crt /etc/ssl/site/server.crt
COPY my_domain.key /etc/ssl/site/server.key
```

#### Using docker run

```shell
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v ./myproject:/var/www/html \
    -v ./my_domain.crt:/etc/ssl/site/server.crt \
    -v ./my_domain.key:/etc/ssl/site/server.key \
    shinsenter/phpfpm-apache:latest
```

#### Using docker-compose

```yml
services:
  web:
    image: shinsenter/phpfpm-apache:latest
    volumes:
      - ./myproject:/var/www/html
      - ./my_domain.crt:/etc/ssl/site/server.crt
      - ./my_domain.key:/etc/ssl/site/server.key
```


## Customize Apache

You can add your Apache configurations by mounting or copying your `*.conf` files into the `/etc/apache2/custom.d/` directory of the container.
The config files here will be loaded into the Apache's default virtual host.

> ⚠️ Note: Since there are already some common configs in this directory, please avoid mounting or replacing an entire different directory into `/etc/apache2/custom.d/`.


## Supported Platforms

Check our [Docker Hub](https://hub.docker.com/r/shinsenter/phpfpm-apache/tags) for all available platforms. The Docker images are available for both Debian and Alpine versions.


## Stable Image Tags

The release versions on [this GitHub repository](https://code.shin.company/php) don't guarantee
that Docker images built from the same source code will always be identical.

We build new Docker images daily to ensure they stay up-to-date
with the latest upstream updates for PHP, base OS, Composer, etc.
The images in this repo are regularly updated under the same tag names.

But you can pull the image from `shinsenter/phpfpm-apache:latest`,
and tag it with a name that indicates its stability,
such as `your-repo/phpfpm-apache:stable` using the below commands:

```shell
docker pull shinsenter/phpfpm-apache:latest
docker tag  shinsenter/phpfpm-apache:latest your-repo/phpfpm-apache:stable
docker push your-repo/phpfpm-apache:stable
```

Then use the image `your-repo/phpfpm-apache:stable` as a base image to build containers for production.


## Contributing

If you find these images useful, consider donating via [PayPal](https://www.paypal.me/shinsenter) or opening an issue on [GitHub](https://code.shin.company/php/issues/new).

Your support helps maintain and improve these images for the community.


## License

This project is licensed under the terms of the [GNU General Public License v3.0](https://code.shin.company/php/blob/main/LICENSE).

Thank you for recognizing the intellectual effort behind this project. If you plan to use or build upon any of its ideas, I kindly ask that you give appropriate credit.

---

From Vietnam 🇻🇳 with love.

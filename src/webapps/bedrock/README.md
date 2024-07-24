# shinsenter/bedrock

🔋 (PHP / Wordpress) Production-ready container with automatic Bedrock Wordpress installer.

> Docker Hub: https://hub.docker.com/r/shinsenter/bedrock

## Introduction

Built on top of [our PHP Docker images](https://hub.docker.com/r/shinsenter/php),
these images allow easy tuning of PHP and PHP-FPM settings through environment variables,
eliminating the need to rebuild images when changing configurations.

These images also include the latest version of [Composer](https://getcomposer.org) and [WP-CLI](https://wp-cli.org),
allowing you to get started with your projects faster without additional installation.

> 💡 Hint: WP-CLI, available as the `wp` command, lets you update plugins,
configure multisite installations and much more, without using a web browser.

> 💡 Hint: Docker image tags ending in `-alpine` or `-tidy` indicate Docker images built on the Alpine Linux base operating system.
> These Docker images are lightweight, helping to speed up builds and save bandwidth for your CI/CD pipelines.

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
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v ./myproject:/var/www/html \
    shinsenter/bedrock:latest
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

To use valid HTTPS certificates for your production website,
you need to replace these files with your own valid SSL certificates
by copying or mounting them from the host machine into the container.
Simply overwrite the default certificate files with your own valid
certificate and key files to enable true HTTPS for your production website.

#### Using Dockerfile

```Dockerfile
FROM shinsenter/bedrock:latest

# Copy your own certs into the container
COPY my_domain.crt /etc/ssl/site/server.crt
COPY my_domain.key /etc/ssl/site/server.key

# You may add your constructions from here
# For example:
# ADD --chown=$APP_USER:$APP_GROUP ./myproject/ /var/www/html/
```

#### Using docker run

```shell
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v ./myproject:/var/www/html \
    -v ./my_domain.crt:/etc/ssl/site/server.crt \
    -v ./my_domain.key:/etc/ssl/site/server.key \
    shinsenter/bedrock:latest
```

#### Using docker-compose

```yml
services:
  web:
    image: shinsenter/bedrock:latest
    volumes:
      - ./myproject:/var/www/html
      - ./my_domain.crt:/etc/ssl/site/server.crt
      - ./my_domain.key:/etc/ssl/site/server.key
```

## Contributing

If you find these images useful, consider donating via [PayPal](https://www.paypal.me/shinsenter) or opening an issue on [Github](https://github.com/shinsenter/php/issues/new).

Your support helps maintain and improve these images for the community.

## License

This project is licensed under the terms of the [GNU General Public License v3.0](https://code.shin.company/php/blob/main/LICENSE).

I appreciate you respecting my intellectual efforts in creating them. If you intend to copy or use ideas from this project, please give proper credit.

---

From Vietnam 🇻🇳 with love.
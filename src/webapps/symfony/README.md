# shinsenter/symfony

🔋 (PHP / Symfony) Production-ready Docker images with automatic Symfony installer.

- Docker Hub: https://hub.docker.com/r/shinsenter/symfony
- GitHub Packages: https://code.shin.company/php/pkgs/container/symfony
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
mkdir symfony
```

2. Run the container and mount the empty directory as a volume. For example:

```shell
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v ./symfony:/var/www/html \
    shinsenter/symfony:latest
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
FROM shinsenter/symfony:latest

# Copy your own certs into the container
COPY my_domain.crt /etc/ssl/site/server.crt
COPY my_domain.key /etc/ssl/site/server.key

# Add your instructions here
# For example:
# ADD --chown=$APP_USER:$APP_GROUP ./symfony/ /var/www/html/
```

#### Using docker run

```shell
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v ./symfony:/var/www/html \
    -v ./my_domain.crt:/etc/ssl/site/server.crt \
    -v ./my_domain.key:/etc/ssl/site/server.key \
    shinsenter/symfony:latest
```

#### Using docker-compose

```yml
services:
  web:
    image: shinsenter/symfony:latest
    volumes:
      - ./symfony:/var/www/html
      - ./my_domain.crt:/etc/ssl/site/server.crt
      - ./my_domain.key:/etc/ssl/site/server.key
```


## Stable Image Tags

The release versions on [this GitHub repository](https://code.shin.company/php) don't guarantee
that Docker images built from the same source code will always be identical.

We build new Docker images daily to ensure they stay up-to-date
with the latest upstream updates for PHP, base OS, Composer, etc.
The images in this repo are regularly updated under the same tag names.

But you can pull the image from `shinsenter/symfony:latest`,
and tag it with a name that indicates its stability,
such as `your-repo/symfony:stable` using the below commands:

```shell
docker pull shinsenter/symfony:latest
docker tag  shinsenter/symfony:latest your-repo/symfony:stable
docker push your-repo/symfony:stable
```

Then use the image `your-repo/symfony:stable` as a base image to build containers for production.


## Contributing

If you find these images useful, consider donating via [PayPal](https://www.paypal.me/shinsenter) or opening an issue on [GitHub](https://code.shin.company/php/issues/new).


## License

This project is licensed under the terms of the [GNU General Public License v3.0](https://code.shin.company/php/blob/main/LICENSE).

Please respect the work that went into these images. If you reuse ideas from this project, credit is appreciated.

---

From Vietnam 🇻🇳 with love.

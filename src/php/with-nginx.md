# shinsenter/phpfpm-nginx

🌏 (PHP) PHP + Nginx Docker images for both production and development.

- Docker Hub: https://hub.docker.com/r/shinsenter/phpfpm-nginx
- GitHub Packages: https://code.shin.company/php/pkgs/container/phpfpm-nginx


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
    shinsenter/phpfpm-nginx:latest
```

[![shinsenter/php](https://repository-images.githubusercontent.com/458053748/17acf331-c504-4105-b692-1c0c02337085)](https://docker.shin.company/php)

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
FROM shinsenter/phpfpm-nginx:latest

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
    shinsenter/phpfpm-nginx:latest
```

#### Using docker-compose

```yml
services:
  web:
    image: shinsenter/phpfpm-nginx:latest
    volumes:
      - ./myproject:/var/www/html
      - ./my_domain.crt:/etc/ssl/site/server.crt
      - ./my_domain.key:/etc/ssl/site/server.key
```


## Customize Nginx

You can add your Nginx configurations by mounting or copying your `*.conf` files into the `/etc/nginx/custom.d/` directory of the container.
The config files here will be loaded into the Nginx's default server.

> ⚠️ Note: Since there are already some common configs in this directory, please avoid mounting or replacing an entire different directory into `/etc/nginx/custom.d/`.


## Supported Platforms

Check our [Docker Hub](https://hub.docker.com/r/shinsenter/phpfpm-nginx/tags) for all available platforms. The Docker images are available for both Debian and Alpine versions.

> ℹ️ Note: We no longer maintain the `-tidy` tag names. If you are using Docker images with this tag, please replace them with the `-alpine` variant.


## Stable Image Tags

The release versions on [this GitHub repository](https://code.shin.company/php) don't guarantee
that Docker images built from the same source code will always be identical.

We build new Docker images daily to ensure they stay up-to-date
with the latest upstream updates for PHP, base OS, Composer, etc.
The images in this repo are regularly updated under the same tag names.

But you can pull the image from `shinsenter/phpfpm-nginx:latest`,
and tag it with a name that indicates its stability,
such as `your-repo/phpfpm-nginx:stable` using the below commands:

```shell
docker pull shinsenter/phpfpm-nginx:latest
docker tag  shinsenter/phpfpm-nginx:latest your-repo/phpfpm-nginx:stable
docker push your-repo/phpfpm-nginx:stable
```

Then use the image `your-repo/phpfpm-nginx:stable` as a base image to build containers for production.


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

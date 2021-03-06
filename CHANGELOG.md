# Changelog

## 2.2.0 - 2022-07-01

Use [S6 Overlay v3.1.1.2](https://github.com/just-containers/s6-overlay/releases/tag/v3.1.1.2).


## 2.1.0 - 2022-06-24

Use [S6 Overlay v3.1.1.1](https://github.com/just-containers/s6-overlay/releases/tag/v3.1.1.1).


## 2.0.0 - 2022-06-10

Hello Ubuntu Jammy (22.04 LTS)!

Ubuntu 22.04 LTS “Jammy Jellyfish” was released on April 21, 2022.

So I decided that new Docker images from the v2.0 releases should be built from this Ubuntu version to ensure they are up to date with system security patches.

[![Docker Pulls](https://img.shields.io/docker/pulls/shinsenter/php)](https://docker.shin.company/php) [![Docker Image Size](https://img.shields.io/docker/image-size/shinsenter/php/latest?label=shinsenter%2Fphp)](https://docker.shin.company/php)

---

I also added more popular PHP open source projects:

- [![`shinsenter/cakephp4`](https://img.shields.io/docker/image-size/shinsenter/cakephp4/latest?label=shinsenter%2Fcakephp4)](https://docker.shin.company/cakephp4)
- [![`shinsenter/codeigniter4`](https://img.shields.io/docker/image-size/shinsenter/codeigniter4/latest?label=shinsenter%2Fcodeigniter4)](https://docker.shin.company/codeigniter4)
- [![`shinsenter/crater`](https://img.shields.io/docker/image-size/shinsenter/crater/latest?label=shinsenter%2Fcrater)](https://docker.shin.company/crater)
- [![`shinsenter/flarum`](https://img.shields.io/docker/image-size/shinsenter/flarum/latest?label=shinsenter%2Fflarum)](https://docker.shin.company/flarum)
- [![`shinsenter/fuelphp`](https://img.shields.io/docker/image-size/shinsenter/fuelphp/latest?label=shinsenter%2Ffuelphp)](https://docker.shin.company/fuelphp)
- [![`shinsenter/grav`](https://img.shields.io/docker/image-size/shinsenter/grav/latest?label=shinsenter%2Fgrav)](https://docker.shin.company/grav)
- [![`shinsenter/hyperf`](https://img.shields.io/docker/image-size/shinsenter/hyperf/latest?label=shinsenter%2Fhyperf)](https://docker.shin.company/hyperf)
- [![`shinsenter/kirby`](https://img.shields.io/docker/image-size/shinsenter/kirby/latest?label=shinsenter%2Fkirby)](https://docker.shin.company/kirby)
- [![`shinsenter/laminas`](https://img.shields.io/docker/image-size/shinsenter/laminas/latest?label=shinsenter%2Flaminas)](https://docker.shin.company/laminas)
- [![`shinsenter/laravel`](https://img.shields.io/docker/image-size/shinsenter/laravel/latest?label=shinsenter%2Flaravel)](https://docker.shin.company/laravel)
- [![`shinsenter/phpmyadmin`](https://img.shields.io/docker/image-size/shinsenter/phpmyadmin/latest?label=shinsenter%2Fphpmyadmin)](https://docker.shin.company/phpmyadmin)
- [![`shinsenter/symfony`](https://img.shields.io/docker/image-size/shinsenter/symfony/latest?label=shinsenter%2Fsymfony)](https://docker.shin.company/symfony)
- [![`shinsenter/slim`](https://img.shields.io/docker/image-size/shinsenter/slim/latest?label=shinsenter%2Fslim)](https://docker.shin.company/slim)
- [![`shinsenter/statamic`](https://img.shields.io/docker/image-size/shinsenter/statamic/latest?label=shinsenter%2Fstatamic)](https://docker.shin.company/statamic)
- [![`shinsenter/wordpress`](https://img.shields.io/docker/image-size/shinsenter/wordpress/latest?label=shinsenter%2Fwordpress)](https://docker.shin.company/wordpress)
- [![`shinsenter/yii`](https://img.shields.io/docker/image-size/shinsenter/yii/latest?label=shinsenter%2Fyii)](https://docker.shin.company/yii)

---

Let's enjoy! ☺️


## 1.7.0 - 2022-03-17

Upgraded Apache2 to v2.4.53 to fix these vulnerabilities.

- [CVE-2022-22720](http://people.ubuntu.com/~ubuntu-security/cve/CVE-2022-22720)
- [CVE-2022-22719](http://people.ubuntu.com/~ubuntu-security/cve/CVE-2022-22719)
- [CVE-2022-23943](http://people.ubuntu.com/~ubuntu-security/cve/CVE-2022-23943)

Improved the docker build workflow.


## 1.6.0 - 2022-03-13

Added images which contain only the unpacked s6-overlay as a multi-platform build stage.

> https://docker.shin.company/s6-overlay

[![Docker Pulls](https://img.shields.io/docker/pulls/shinsenter/s6-overlay)](https://docker.shin.company/s6-overlay) [![Docker Image Size](https://img.shields.io/docker/image-size/shinsenter/s6-overlay/latest?label=shinsenter%2Fs6-overlay)](https://docker.shin.company/s6-overlay)

### Usage

The `shinsenter/s6-overlay` image is not intended to be used directly, but rather consumed in other Dockerfiles as a multi-platform and reusable build stage.

```Dockerfile
FROM ubuntu:latest

# adds file from the shinsenter/s6-overlay image
COPY --from=shinsenter/s6-overlay / /

# important: sets s6-overlay entrypoint
ENTRYPOINT ["/init"]

# runs other commands
RUN ...
```


## 1.5.0 - 2022-03-12

- Small bug fixes.
- Added README.md for each image page.


## 1.4.0 - 2022-03-09

All files and folders in previous images that were granted 777 permissions have been modified with default permissions (755 for folders and 644 for files).


## 1.3.0 - 2022-03-08

- Use S6 Overlay v3.1.0.1
- Small bug fixes


## 1.2.0 - 2022-03-07

Added Symfony images.


## 1.1.0 - 2022-03-07

Unify the WEBHOME environment variable for all Docker images.

```Dockerfile
################################################################################

# You can change the home of the web user if needed
ENV WEBHOME="/var/www/html"

################################################################################
```

For Apache and Nginx base images, there are additional environment variables to specify to the root directory within this WEBHOME directory.

### shinsenter/php:fpm-apache

```Dockerfile
################################################################################

# Sets the directory from which Apache will serve files
ENV WEBHOME="/var/www/html"

# Set Apache root folder within $WEBHOME
# E.g: APACHE_DOCUMENT_ROOT="/public"
ENV APACHE_DOCUMENT_ROOT=""

################################################################################
```

### shinsenter/php:fpm-nginx

```Dockerfile
################################################################################

# Sets the directory from which Nginx will serve files
ENV WEBHOME="/var/www/html"

# Set Nginx root folder within $WEBHOME
# E.g: NGINX_DOCUMENT_ROOT="/public"
ENV NGINX_DOCUMENT_ROOT=""

################################################################################
```


## 1.0.0 - 2022-03-04

### The very first release

Docker images for PHP applications, from CLI to standalone web server.

> https://docker.shin.company/php/tags

[![Docker Pulls shinsenter/php](https://img.shields.io/docker/pulls/shinsenter/php)](https://docker.shin.company/php)

---

## Community

As an open source project, we'd appreciate any help and contributions!

[![Become a stargazer](https://img.shields.io/badge/Become-Stargazer-yellow)](https://code.shin.company/php/stargazers) [![Report an issue](https://img.shields.io/badge/New-Discussions-green)](https://code.shin.company/php/discussions/new) [![Join us on Gitter](https://badges.gitter.im/shinsenter/php.svg)](https://gitter.im/shinsenter/php?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) [![Join us on Discord](https://img.shields.io/discord/962919929307357234?color=blueviolet)](https://discord.com/channels/962919929307357234/962920416559652924)

We follow the standard [github pull request process](https://help.github.com/articles/about-pull-requests). It is appreciated when you [report an issue](https://code.shin.company/php/issues/new/choose) or event  [start a discussion](https://code.shin.company/php/discussions/new). We'll try to review your contributions as soon as possible.

Not ready to contribute code, but see something that needs work? From contributing to source code to improving readability of the documentation, all suggestions are welcome!

## Support my activities

If you like this repository, please [become a stargazer](https://code.shin.company/php/stargazers) on my Github or join Gitter to follow further updates.

I also love to have your help, please consider buying me a coffee, or sponsoring my works so I can create more helpful stuffs 😉.

[![Donate via PayPal](https://img.shields.io/badge/Donate-Paypal-blue)](https://www.paypal.me/shinsenter) [![Become a sponsor](https://img.shields.io/badge/Donate-Patreon-orange)](https://www.patreon.com/appseeds)

I really appreciate your love and supports.

* * *

Explore more Docker images at [docker.shin.company](https://docker.shin.company).

<!-- From Vietnam 🇻🇳 with love. -->
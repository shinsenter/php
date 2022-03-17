# Changelog

## 1.7.0 - 2022-03-17

Upgraded Apache2 to v2.4.53 to fix these vulnerabilities.

- [CVE-2022-22720](http://people.ubuntu.com/~ubuntu-security/cve/CVE-2022-22720)
- [CVE-2022-22719](http://people.ubuntu.com/~ubuntu-security/cve/CVE-2022-22719)
- [CVE-2022-23943](http://people.ubuntu.com/~ubuntu-security/cve/CVE-2022-23943)

Improved the docker build workflow.

## 1.6.0 - 2022-03-13

Added images which contain only the unpacked s6-overlay as a multi-platform build stage.

https://hub.docker.com/r/shinsenter/s6-overlay

[![Docker Pulls](https://img.shields.io/docker/pulls/shinsenter/s6-overlay)](https://hub.docker.com/r/shinsenter/s6-overlay) [![Docker Image Size](https://img.shields.io/docker/image-size/shinsenter/s6-overlay/latest?label=shinsenter%2Fs6-overlay)](https://hub.docker.com/r/shinsenter/s6-overlay/tags)

### Usage

The `shinsenter/s6-overlay` image is not intended to be used directly, but rather consumed in other Dockerfiles as a multi-platform and reusable build stage.

```Dockerfile
FROM ubuntu

# adds file from the shinsenter/s6-overlay image
COPY --from=shinsenter/s6-overlay / /
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

## The very first release

Docker images for PHP applications, from CLI to standalone web server.

https://hub.docker.com/r/shinsenter/php/tags

[![Docker Pulls shinsenter/php](https://img.shields.io/docker/pulls/shinsenter/php)](https://hub.docker.com/r/shinsenter/php/tags)


---

## Support my activities

If you like this repository, please [hit the star button](https://github.com/shinsenter/php/stargazers) on my Github to follow further updates, or buy me a coffee 😉.

[![Donate via PayPal](https://img.shields.io/badge/Donate-Paypal-blue)](https://www.paypal.me/shinsenter) [![Become a sponsor](https://img.shields.io/badge/Donate-Patreon-orange)](https://www.patreon.com/appseeds) [![Become a stargazer](https://img.shields.io/badge/Support-Stargazer-yellow)](https://github.com/shinsenter/php/stargazers) [![Report an issue](https://img.shields.io/badge/Support-Issues-green)](https://github.com/shinsenter/php/discussions/new) [![Join the chat at https://gitter.im/shinsenter/php](https://badges.gitter.im/shinsenter/php.svg)](https://gitter.im/shinsenter/php?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

I really appreciate your love and supports.


---

From Vietnam 🇻🇳 with love.

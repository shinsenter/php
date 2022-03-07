# Changelog

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

## Support my activities

If you like this repository, please hit the star button to follow further updates, or buy me a coffee 😉.

[![Donate via PayPal](https://img.shields.io/badge/Donate-Paypal-blue)](https://www.paypal.me/shinsenter) [![Become a sponsor](https://img.shields.io/badge/Donate-Patreon-orange)](https://www.patreon.com/appseeds) [![Become a stargazer](https://img.shields.io/badge/Support-Stargazer-yellow)](https://github.com/shinsenter/docker-imgproxy/stargazers) [![Report an issue](https://img.shields.io/badge/Support-Issues-green)](https://github.com/shinsenter/docker-imgproxy/discussions/new) [![Join the chat at https://gitter.im/shinsenter/php](https://badges.gitter.im/shinsenter/php.svg)](https://gitter.im/shinsenter/php?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

I really appreciate your love and supports.

From Vietnam 🇻🇳 with love.

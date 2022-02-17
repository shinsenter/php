# This file is the work of https://github.com/shinsenter/php
################################################################################

ARG BASE_IMAGE=shinsenter/php
ARG PHP_VERSION=8.1

# base image and platform
FROM ${BASE_IMAGE}:${PHP_VERSION}-fpm-nginx

# updates document root path
ENV NGINX_DOCUMENT_ROOT=$WEBHOME/public

# installs php-swoole
RUN apt-update && apt-install php${PHP_VERSION}-swoole \
    && apt-cleanup

# adds config files
ADD etc/ /etc/
ADD usr/ /usr/

# set more env variables
ENV LARAVEL_AUTO_OPTIMIZE=true
ENV LARAVEL_LINK_STORAGE=true
ENV LARAVEL_AUTO_MIGRATION=false

ENTRYPOINT ["/init"]

################################################################################
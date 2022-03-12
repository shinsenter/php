# This file is the work of https://github.com/shinsenter/php
################################################################################

ARG BASE_IMAGE=shinsenter/phpfpm-nginx
ARG PHP_VERSION=8.1

################################################################################

# base image and platform
FROM ${BASE_IMAGE}:php${PHP_VERSION}

# installs php-swoole
RUN apt-update && apt-install php${PHP_VERSION}-swoole \
    && apt-cleanup

# adds config files
ADD root/ /

# sets web server root path
ENV WEBHOME="/var/www/html"
ENV NGINX_DOCUMENT_ROOT="/public"

# sets the working directory
WORKDIR $WEBHOME

################################################################################

# set more env variables
ENV LARAVEL_AUTO_OPTIMIZE=true
ENV LARAVEL_LINK_STORAGE=true
ENV LARAVEL_AUTO_MIGRATION=false

################################################################################

ARG   BUILD_NUMBER
LABEL build_number="$BUILD_NUMBER"
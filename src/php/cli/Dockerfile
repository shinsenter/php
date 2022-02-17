# This file is the work of https://github.com/shinsenter/php
################################################################################

ARG BASE_IMAGE=shinsenter/s6-ubuntu:latest

# base image and platform
FROM ${BASE_IMAGE} as base

ARG PHP_VERSION=8.1
ARG PHP_PPA_KEY="4F4EA0AAE5267A6C"
ARG PHP_PPA_URL="http://ppa.launchpad.net/ondrej/php/ubuntu"
ARG PHP_SOURCES="/etc/apt/sources.list.d/ondrej-php.list"
ARG PHP_BUILD_DEP="ca-certificates unzip"

# php version
ENV PHP_VERSION=${PHP_VERSION}
ADD php${PHP_VERSION}.txt /usr/src/php${PHP_VERSION}.txt

RUN echo "Installing PHP ${PHP_VERSION}..." \
    && apt-update && apt-install sudo less gnupg \
    \
    # adds ondrej repos for PHP
    && add-ppa $PHP_PPA_URL $PHP_SOURCES $PHP_PPA_KEY \
    \
    # installs php
    && apt-update \
    && apt-install ${PHP_BUILD_DEP} $(cat /usr/src/php${PHP_VERSION}.txt) \
    && swap-dir /etc/php/${PHP_VERSION}/cli /etc/php/cli \
    \
    # cleanup
    && apt-cleanup

# adds composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

################################################################################

# main image
FROM base

# adds config files
ADD etc/ /etc/

CMD ["php", "-a"]

################################################################################
# This file is the work of https://github.com/shinsenter/php
################################################################################

ARG BASE_IMAGE=shinsenter/s6-ubuntu:latest

################################################################################

# prepares base image
FROM ${BASE_IMAGE}

ARG PHP_VERSION=8.1
ARG PHP_PPA_KEY="4F4EA0AAE5267A6C"
ARG PHP_PPA_URL="http://ppa.launchpad.net/ondrej/php/ubuntu"
ARG PHP_SOURCES="/etc/apt/sources.list.d/ondrej-php.list"
ARG PHP_BUILD_DEP="unzip"

# adds variables for PHP and Composer
ENV PHP_VERSION=${PHP_VERSION}
ADD php${PHP_VERSION}.txt /usr/src/php${PHP_VERSION}.txt

# installs PHP and Composer
RUN echo "Installing PHP ${PHP_VERSION}..." \
    && apt-update && apt-install sudo gnupg \
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

# creates folder for composer
RUN webuser-mkdir /composer

################################################################################

# adds config files
ADD root/ /

# sets default command
CMD ["php", "-a"]

################################################################################

# adds composer settings
ENV COMPOSER_HOME=/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_MAX_PARALLEL_HTTP=32
ENV PATH /composer/vendor/bin:$PATH
ENV PHP_CONF_DIR=/etc/php/cli/conf.d

################################################################################

ARG   BUILD_NUMBER
LABEL build_number="$BUILD_NUMBER"
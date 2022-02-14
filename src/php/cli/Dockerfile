# This pipeline will keep image size as small as possible.
################################################################################

# base image and platform
FROM ${BASE_IMAGE:-shinsenter/s6-ubuntu:focal} as base

ARG PHP_PPA_URL="http://ppa.launchpad.net/ondrej/php/ubuntu"
ARG PHP_PPA_KEY="14AA40EC0831756756D7F66C4F4EA0AAE5267A6C"
ARG PHP_SOURCES="/etc/apt/sources.list.d/ondrej-php.list"
ARG PHP_BUILD_DEP="ca-certificates unzip"

# php version
ENV PHP_VERSION=${PHP_VERSION:-7.4}
ADD php${PHP_VERSION}.txt /usr/src/php${PHP_VERSION}.txt

RUN apt-update && apt-install gnupg \
    \
    # adds ondrej repos for Ubuntu
    && echo "deb $PHP_PPA_URL ${OS_VERSION:-focal} main" >$PHP_SOURCES \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $PHP_PPA_KEY 2>/dev/null \
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
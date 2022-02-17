# This file is the work of https://github.com/shinsenter/php
################################################################################

ARG BASE_IMAGE=shinsenter/php
ARG PHP_VERSION=8.1

# base image and platform
FROM ${BASE_IMAGE}:${PHP_VERSION}-fpm-apache as base

################################################################################

FROM base as source

ARG WPCLI_URL=https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

RUN apt-update && apt-install wget \
    && wget -O  /usr/bin/wp-cli "$WPCLI_URL" \
    && chmod +x /usr/bin/wp-cli

################################################################################

# main image
FROM base

# updates document root path
ENV APACHE_DOCUMENT_ROOT=$WEBHOME

# adds config files
COPY --from=source /usr/bin/wp-cli /usr/bin/wp-cli
ADD  etc/ /etc/
ADD  usr/ /usr/

# set more env variables
ENV WORDPRESS_LOCALE="en_US"

ENTRYPOINT ["/init"]

################################################################################
# This file is the work of https://github.com/shinsenter/php
################################################################################

ARG BASE_IMAGE=shinsenter/php
ARG PHP_VERSION=8.1

################################################################################

# base image and platform
FROM ${BASE_IMAGE}:${PHP_VERSION}-fpm-apache as base

################################################################################

FROM base as source

ARG WPCLI_URL=https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
ADD $WPCLI_URL /usr/bin/wp-cli
RUN chmod +x /usr/bin/wp-cli

################################################################################

# main image
FROM base

# adds config files
COPY --from=source /usr/bin/wp-cli /usr/bin/wp-cli
ADD  root/ /

# updates document root path
ENV APACHE_DOCUMENT_ROOT=$WEBHOME

# sets the working directory
WORKDIR $APACHE_DOCUMENT_ROOT

################################################################################

# set more env variables
ENV WORDPRESS_LOCALE="en_US"

################################################################################

ARG   BUILD_NUMBER
LABEL build_number="$BUILD_NUMBER"
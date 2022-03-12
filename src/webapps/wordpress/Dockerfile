# This file is the work of https://github.com/shinsenter/php
################################################################################

ARG BASE_IMAGE=shinsenter/phpfpm-apache
ARG PHP_VERSION=8.1

################################################################################

# base image and platform
FROM ${BASE_IMAGE}:php${PHP_VERSION} as base

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

# sets web server root path
ENV WEBHOME="/var/www/html"
ENV APACHE_DOCUMENT_ROOT=""

# sets the working directory
WORKDIR $WEBHOME

################################################################################

# set more env variables
ENV WORDPRESS_LOCALE="en_US"

################################################################################

ARG   BUILD_NUMBER
LABEL build_number="$BUILD_NUMBER"
# This file belongs to the project https://code.shin.company/php
# Author:  Shin <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ARG BASE_IMAGE=shinsenter/phpfpm-apache
ARG IMAGE_SUFFIX="-tidy"
ARG PHP_VERSION=8.1

################################################################################

# base image
FROM ${BASE_IMAGE}:php${PHP_VERSION}${IMAGE_SUFFIX}

# sets web server root path
ENV APACHE_DOCUMENT_ROOT=""

################################################################################

# adds config files
ADD root/ /

# installs wp-cli
ARG WPCLI_URL=https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN php -r "copy('$WPCLI_URL', '/usr/bin/wp-cli');" && chmod +xr /usr/bin/wp-cli

# sets the working directory
# WORKDIR $WEBHOME

################################################################################

# overrides parents env variables
ENV ENABLE_CRONTAB=true
ENV PHP_ERROR_REPORTING="E_ALL & ~E_DEPRECATED & ~E_STRICT & ~E_WARNING"
ENV PHP_MAX_EXECUTION_TIME=300
ENV PHP_POST_MAX_SIZE=100M
ENV PHP_UPLOAD_MAX_FILE_SIZE=10M

# set more env variables
ENV WORDPRESS_LOCALE="en_US"

################################################################################
# This file belongs to the project https://code.shin.company/php
# Author:  Shin <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ARG BASE_IMAGE=shinsenter/phpfpm-apache
ARG IMAGE_SUFFIX="-tidy"
ARG PHP_VERSION=8.2

################################################################################

# base image
FROM ${BASE_IMAGE}:php${PHP_VERSION}${IMAGE_SUFFIX}

# sets web server root path
ENV APACHE_DOCUMENT_ROOT="/docroot"

################################################################################

# adds config files
ADD root/ /

# installs PHP modules
RUN phpaddmod imap

# sets the working directory
# WORKDIR $WEBHOME

################################################################################

# recommended settings
ENV PHP_MEMORY_LIMIT=512M
ENV PHP_POST_MAX_SIZE=100M
ENV PHP_UPLOAD_MAX_FILE_SIZE=10M

# set more env variables
ENV MAUTIC_PROJECT="mautic/recommended-project"

################################################################################
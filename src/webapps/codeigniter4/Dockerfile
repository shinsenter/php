# This file is the work of https://github.com/shinsenter/php
################################################################################

ARG BASE_IMAGE=shinsenter/php
ARG PHP_VERSION=8.1

################################################################################

# base image and platform
FROM ${BASE_IMAGE}:${PHP_VERSION}-fpm-apache

# adds config files
ADD root/ /

# updates document root path
ENV APACHE_DOCUMENT_ROOT=$WEBHOME/public

# sets the working directory
WORKDIR $WEBHOME

################################################################################

ARG   BUILD_NUMBER
LABEL build_number="$BUILD_NUMBER"
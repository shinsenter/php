# This file is the work of https://github.com/shinsenter/php
################################################################################

ARG BASE_IMAGE=shinsenter/php
ARG PHP_VERSION=8.1

################################################################################

# base image and platform
FROM ${BASE_IMAGE}:${PHP_VERSION}-fpm-nginx

# adds config files
ADD root/ /

# updates document root path
ENV WEBHOME=/var/www/html
ENV NGINX_DOCUMENT_ROOT=/public

# sets the working directory
WORKDIR /var/www/html/

################################################################################

# set more env variables
ENV SYMFONY_INSTALL_DEVKIT=false

################################################################################

ARG   BUILD_NUMBER
LABEL build_number="$BUILD_NUMBER"
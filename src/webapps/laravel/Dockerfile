# This file belongs to the project https://code.shin.company/php
# Author:  Shin <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ARG BASE_IMAGE=shinsenter/phpfpm-nginx
ARG IMAGE_SUFFIX="-tidy"
ARG PHP_VERSION=8.2

################################################################################

# base image
FROM ${BASE_IMAGE}:php${PHP_VERSION}${IMAGE_SUFFIX}

# sets web server root path
ENV NGINX_DOCUMENT_ROOT="/public"

################################################################################

# adds config files
ADD root/ /

# sets the working directory
# WORKDIR $WEBHOME

################################################################################

# set more env variables
ENV ENABLE_CRONTAB=true
ENV LARAVEL_AUTO_MIGRATION=false
ENV LARAVEL_AUTO_OPTIMIZE=false
ENV LARAVEL_LINK_STORAGE=true
ENV LARAVEL_QUEUE_OPTIONS=
ENV LARAVEL_QUEUE_ENABLED=false
ENV LARAVEL_SCHEDULE_OPTIONS=
ENV LARAVEL_SCHEDULE_ENABLED=false

################################################################################
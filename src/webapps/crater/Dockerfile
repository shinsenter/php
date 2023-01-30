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
ENV CRATER_AUTO_MIGRATION=false
ENV CRATER_AUTO_OPTIMIZE=false
ENV CRATER_LINK_STORAGE=true
ENV CRATER_QUEUE_OPTIONS=
ENV CRATER_QUEUE_ENABLED=false
ENV CRATER_SCHEDULE_OPTIONS=
ENV CRATER_SCHEDULE_ENABLED=true

################################################################################
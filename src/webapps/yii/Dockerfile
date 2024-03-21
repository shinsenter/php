# This file belongs to the project https://code.shin.company/php
# Author:  Shin <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ARG BASE_IMAGE=shinsenter/phpfpm-apache
ARG IMAGE_SUFFIX="-tidy"
ARG PHP_VERSION=8.3

################################################################################

# base image
FROM ${BASE_IMAGE}:php${PHP_VERSION}${IMAGE_SUFFIX}-deprecated

# sets web server root path
ENV APACHE_DOCUMENT_ROOT="/web"

################################################################################

# adds config files
ADD root/ /

# sets the working directory
# WORKDIR $WEBHOME

################################################################################

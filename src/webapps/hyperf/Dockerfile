# This file belongs to the project https://code.shin.company/php
# Author:  Shin <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ARG BASE_IMAGE=shinsenter/phpfpm-nginx
ARG IMAGE_SUFFIX="-tidy"
ARG PHP_VERSION=8.3

################################################################################

# base image
FROM ${BASE_IMAGE}:php${PHP_VERSION}${IMAGE_SUFFIX}

# sets web server root path
ENV NGINX_DOCUMENT_ROOT=""

################################################################################

# adds config files
ADD root/ /

# installs PHP modules
RUN phpaddmod protobuf swoole --ignore-missing \
    && echo 'swoole.use_shortname = Off' >>"/etc/php/${PHP_VERSION}/mods-available/swoole.ini"

# sets the working directory
# WORKDIR $WEBHOME

################################################################################
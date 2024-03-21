# This file belongs to the project https://code.shin.company/php
# Author:  Shin <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ARG BASE_IMAGE=shinsenter/php
ARG PHP_VERSION=8.3

################################################################################

# base image
FROM ${BASE_IMAGE}:${PHP_VERSION}-fpm-deprecated

ARG NGINX_BUILD_DEPS="gnupg2 apt-utils"
ARG NGINX_PPA_KEY="4F4EA0AAE5267A6C"
ARG NGINX_PPA_URL="http://ppa.launchpadcontent.net/ondrej/nginx-mainline/ubuntu"

################################################################################

# installs nginx
RUN echo "Installing Nginx" \
    && apt-update \
    && apt-install $NGINX_BUILD_DEPS \
    && apt-deb ppa-nginx $NGINX_PPA_URL $NGINX_PPA_KEY \
    && apt-install nginx && disable nginx \
    && sed -i '/woff2/d' /etc/nginx/mime.types \
    \
    # cleanup
    && rm -rf /var/log/nginx ${WEBHOME}/*.html \
    && apt-upgrade -uq \
    && cleanup $NGINX_BUILD_DEPS

# adds config files
ADD root/ /

# sets the working directory
# WORKDIR $WEBHOME

# exposes ports
EXPOSE 80
EXPOSE 443
EXPOSE 443/udp

# sets default entrypoint
ENTRYPOINT ["/init"]

################################################################################

# sets env variables
ENV NGINX_DOCUMENT_ROOT=""

# automatically create index.php
ENV AUTO_CREATE_INDEX_FILE="false"

################################################################################

LABEL traefik.enable=true

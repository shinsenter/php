# This file is the work of https://github.com/shinsenter/php
################################################################################

ARG BASE_IMAGE=shinsenter/php
ARG PHP_VERSION=8.1

################################################################################

# base image and platform
FROM ${BASE_IMAGE}:${PHP_VERSION}-fpm

ARG NGINX_PPA_KEY="4F4EA0AAE5267A6C"
ARG NGINX_PPA_URL="http://ppa.launchpadcontent.net/ondrej/nginx-mainline/ubuntu"
ARG NGINX_SOURCES="/etc/apt/sources.list.d/ondrej-nginx.list"

RUN echo "Installing Nginx..." \
    \
    # adds ondrej repos for Nginx
    && add-ppa $NGINX_PPA_URL $NGINX_SOURCES $NGINX_PPA_KEY \
    \
    # installs nginx, msmtp
    && apt-update \
    && apt-install msmtp msmtp-mta \
    && apt-install nginx \
    && service nginx stop && update-rc.d nginx disable \
    && rm -f ${WEBHOME}/*.html \
    \
    # makes log files
    && webuser-mkdir /var/log/nginx \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    \
    # cleanup
    && rm -f $NGINX_SOURCES \
    && apt-cleanup

################################################################################

# adds config files
ADD root/ /

# sets the working directory
WORKDIR $WEBHOME

# exposes ports
EXPOSE 80
EXPOSE 443
EXPOSE 443/udp

################################################################################

# sets env variables
ENV DEBUG_MODE=false
ENV MSMTP_RELAY_SERVER_HOSTNAME=mailhog
ENV MSMTP_RELAY_SERVER_PORT=1025

################################################################################

ARG   BUILD_NUMBER
LABEL build_number="$BUILD_NUMBER"
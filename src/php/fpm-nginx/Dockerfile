# This pipeline will keep image size as small as possible.
################################################################################

# base image and platform
FROM ${IMAGE_NAME:-shinsenter/php}:${PHP_VERSION:-7.4}-fpm as base

ARG NGINX_PPA_URL="https://ppa.launchpadcontent.net/ondrej/nginx-mainline/ubuntu"
ARG NGINX_PPA_KEY="14AA40EC0831756756D7F66C4F4EA0AAE5267A6C"
ARG NGINX_SOURCES="/etc/apt/sources.list.d/ondrej-nginx.list"

RUN apt-update \
    \
    # adds ondrej repos for Ubuntu
    && echo "deb $NGINX_PPA_URL ${OS_VERSION:-focal} main" >$NGINX_SOURCES \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $NGINX_PPA_KEY 2>/dev/null \
    \
    # installs nginx, msmtp
    && apt-update \
    && apt-install msmtp msmtp-mta \
    && apt-install nginx-extras \
    && service nginx stop && update-rc.d nginx disable \
    \
    # cleanup
    && apt-cleanup

ENV DEBUG_MODE=false

ENV MSMTP_RELAY_SERVER_HOSTNAME=mailhog
ENV MSMTP_RELAY_SERVER_PORT=1025

################################################################################

# main image
FROM base

# adds config files
ADD etc/ /etc/

# exposes ports
EXPOSE 80
EXPOSE 443
EXPOSE 443/udp

################################################################################
# This pipeline will keep image size as small as possible.
################################################################################

# base image and platform
# FROM ${BASE_IMAGE:-shinsenter/php-fpm:latest} as base
FROM php-fpm as base

ENV MSMTP_RELAY_SERVER_HOSTNAME=mailhog
ENV MSMTP_RELAY_SERVER_PORT=1025

RUN DEBIAN_FRONTEND=noninteractive \
    \
    # adds nginx repos for Ubuntu
    && echo 'deb https://nginx.org/packages/ubuntu/ focal nginx' \
        >/etc/apt/sources.list.d/nginx.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62 \
    && apt-get update \
    \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        msmtp \
        msmtp-mta \
        nginx \
    \
    && apt-get -y autoremove && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

################################################################################

# main image
FROM base

# adds config files
ADD etc/ /etc/

EXPOSE 80
EXPOSE 443
EXPOSE 443/udp

################################################################################
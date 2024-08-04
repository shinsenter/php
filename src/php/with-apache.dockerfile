# syntax = devthefuture/dockerfile-x
################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  SHIN Company <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

# ARG  BUILD_FROM_IMAGE=${BUILD_FROM_IMAGE:-php}
# ARG  PHP_VERSION=${PHP_VERSION:-8.3}
# ARG  PHP_VARIANT=${PHP_VARIANT:-fpm-alpine}

# FROM ./base-php AS php

ARG  BUILD_FROM_IMAGE=${BUILD_FROM_IMAGE:-shinsenter/php}
ARG  PHP_VERSION=${PHP_VERSION:-8.3}
ARG  PHP_VARIANT=${PHP_VARIANT:-fpm-alpine}

FROM ${BUILD_FROM_IMAGE}:${PHP_VERSION}-${PHP_VARIANT}

################################################################################

INCLUDE ./with-apache/apache-install
INCLUDE ./with-apache/apache-config
INCLUDE ./common/os-s6-overlay

RUN apache2 -v

################################################################################

EXPOSE 80
EXPOSE 443
EXPOSE 443/udp

CMD []

################################################################################

INCLUDE ./meta

################################################################################

LABEL traefik.enable=true

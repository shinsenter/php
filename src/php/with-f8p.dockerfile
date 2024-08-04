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
# ARG  PHP_VARIANT=${PHP_VARIANT:-zts-alpine}
# ARG  BUILD_SOURCE_IMAGE=${BUILD_SOURCE_IMAGE:-dunglas/frankenphp:1-php${PHP_VERSION}}

# FROM $BUILD_SOURCE_IMAGE AS frankenphp
# FROM ./base-php AS php

ARG  BUILD_FROM_IMAGE=${BUILD_FROM_IMAGE:-shinsenter/php}
ARG  PHP_VERSION=${PHP_VERSION:-8.3}
ARG  PHP_VARIANT=${PHP_VARIANT:-zts-alpine}
ARG  BUILD_SOURCE_IMAGE=${BUILD_SOURCE_IMAGE:-dunglas/frankenphp:1-php${PHP_VERSION}}

FROM $BUILD_SOURCE_IMAGE AS frankenphp
FROM ${BUILD_FROM_IMAGE}:${PHP_VERSION}-${PHP_VARIANT}

################################################################################

INCLUDE ./with-f8p/f8p-install
INCLUDE ./with-f8p/f8p-config
INCLUDE ./common/os-s6-overlay

RUN frankenphp version

################################################################################

EXPOSE 2019
EXPOSE 80
EXPOSE 443
EXPOSE 443/udp

CMD []
HEALTHCHECK CMD curl -sf http://localhost:2019/metrics || exit 1

################################################################################

INCLUDE ./meta

ARG   BUILD_SOURCE_IMAGE
LABEL build_from="$BUILD_SOURCE_IMAGE"

################################################################################

LABEL traefik.enable=true

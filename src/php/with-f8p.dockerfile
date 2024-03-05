# syntax = devthefuture/dockerfile-x
################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  Mai Nhut Tan <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ARG  BUILD_FROM_IMAGE=${BUILD_FROM_IMAGE:-php}
ARG  PHP_VERSION=${PHP_VERSION:-8.3}
ARG  PHP_VARIANT=${PHP_VARIANT:-zts}
ARG  BUILD_SOURCE_IMAGE=${BUILD_SOURCE_IMAGE:-dunglas/frankenphp:latest-php${PHP_VERSION}}

FROM $BUILD_SOURCE_IMAGE as frankenphp
FROM ./base-php as php

################################################################################

INCLUDE ./with-f8p/f8p-install
INCLUDE ./with-f8p/f8p-config

################################################################################

EXPOSE 2019
EXPOSE 80
EXPOSE 443
EXPOSE 443/udp

CMD []
HEALTHCHECK CMD curl -sf http://localhost:2019/metrics || exit 1

################################################################################

LABEL traefik.enable=true

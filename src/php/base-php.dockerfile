# syntax = devthefuture/dockerfile-x
################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  SHIN Company <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ARG  BUILD_FROM_IMAGE=${BUILD_FROM_IMAGE:-php}
ARG  PHP_VERSION=${PHP_VERSION:-8.3}
ARG  PHP_VARIANT=${PHP_VARIANT:-fpm-alpine}

FROM ${BUILD_FROM_IMAGE}:${PHP_VERSION}-${PHP_VARIANT}

# set PHP variables
ARG PHP_VERSION=${PHP_VERSION:-8.3}
ARG PHP_VARIANT=${PHP_VARIANT:-fpm}
ENV PHP_VERSION=${PHP_VERSION//-rc/}
ENV PHP_VARIANT=$PHP_VARIANT

################################################################################

INCLUDE ./meta
INCLUDE ./common/os-base
INCLUDE ./common/php-extensions
INCLUDE ./common/php-composer
INCLUDE ./common/php-ini-directives
INCLUDE ./common/os-s6-overlay
INCLUDE ./common/os-crontab

################################################################################

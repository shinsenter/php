# syntax = devthefuture/dockerfile-x
################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  Mai Nhut Tan <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ARG  BUILD_FROM_IMAGE=${BUILD_FROM_IMAGE:-shinsenter/phpfpm-apache}
ARG  PHP_VERSION=${PHP_VERSION:-8.3}
ARG  PHP_VARIANT=${PHP_VARIANT:-}

FROM ${BUILD_FROM_IMAGE}:php${PHP_VERSION}${PHP_VARIANT}

################################################################################

INCLUDE ./meta

ADD --link ./rootfs/ /

################################################################################

# https://docs.mautic.org/en/5.x/getting_started/how_to_install_mautic.html#installing-with-composer
ENV DOCUMENT_ROOT="/docroot"
ENV INITIAL_PROJECT="mautic/recommended-project"
ENV DISABLE_GENERATING_INDEX=1
ENV COMPOSER_REQUIRES_GIT=1

################################################################################

RUN web-cmd console 'php $(app-path)/bin/console'
RUN web-cmd mautic  'php $(app-path)/bin/console'

# syntax = devthefuture/dockerfile-x
################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  SHIN Company <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ARG  BUILD_FROM_IMAGE=${BUILD_FROM_IMAGE:-shinsenter/phpfpm-apache}
ARG  PHP_VERSION=${PHP_VERSION:-8.3}
ARG  PHP_VARIANT=${PHP_VARIANT:-}

FROM ${BUILD_FROM_IMAGE}:php${PHP_VERSION}${PHP_VARIANT}

################################################################################

ADD --link ./rootfs/ /

################################################################################

# https://book.cakephp.org/5/en/installation.html
ENV DOCUMENT_ROOT="/webroot"
ENV INITIAL_PROJECT="cakephp/app:~5.0"
ENV DISABLE_AUTORUN_GENERATING_INDEX=1

################################################################################

RUN web-cmd cake '$(app-path)/bin/cake'

################################################################################

INCLUDE ./meta

################################################################################

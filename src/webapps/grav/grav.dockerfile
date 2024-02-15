# syntax = devthefuture/dockerfile-x
################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  Mai Nhut Tan <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ARG  PHP_VERSION=${PHP_VERSION:-8.3}
ARG  PHP_VARIANT=${PHP_VARIANT:-}

FROM shinsenter/phpfpm-apache:php${PHP_VERSION}${PHP_VARIANT}

################################################################################

INCLUDE ./meta

ADD --link ./rootfs/ /

################################################################################

# https://learn.getgrav.org/17/basics/installation
ENV DOCUMENT_ROOT=""
ENV INITIAL_PROJECT="getgrav/grav"
ENV DISABLE_GENERATING_INDEX=1
ENV COMPOSER_REQUIRES_GIT=1

################################################################################

RUN web-cmd grav   'php $(app-path)/bin/grav'
RUN web-cmd gpm    'php $(app-path)/bin/gpm'
RUN web-cmd plugin 'php $(app-path)/bin/plugin'

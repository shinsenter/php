# syntax = devthefuture/dockerfile-x
################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  SHIN Company <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ARG  PHP_VERSION=${PHP_VERSION:-8.3}
ARG  PHP_VARIANT=${PHP_VARIANT:-}

# FROM ../laravel/laravel
FROM shinsenter/phpfpm-nginx:php${PHP_VERSION}${PHP_VARIANT}

################################################################################

INCLUDE ./meta

ADD --link ./rootfs/ /

################################################################################

# https://statamic.dev/installing
ENV DOCUMENT_ROOT="/public"
ENV INITIAL_PROJECT="statamic/statamic"
ENV DISABLE_AUTORUN_GENERATING_INDEX=1

################################################################################

RUN web-cmd artisan 'php $(app-path)/artisan'
RUN web-cmd please  'php $(app-path)/please'

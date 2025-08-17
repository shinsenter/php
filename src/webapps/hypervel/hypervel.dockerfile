# syntax = ghcr.io/shinsenter/dockerfile-x:v1
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

# Enable SBOM attestations
# See: https://docs.docker.com/build/attestations/sbom/
ARG BUILDKIT_SBOM_SCAN_CONTEXT=true
ARG BUILDKIT_SBOM_SCAN_STAGE=true

################################################################################

ARG BUILD_FROM_IMAGE=${BUILD_FROM_IMAGE:-shinsenter/laravel}
ARG BUILD_TAG_PREFIX=${BUILD_TAG_PREFIX:-}

ARG PHP_VERSION=${PHP_VERSION:-8.4}
ARG PHP_VARIANT=${PHP_VARIANT:-}

FROM ${BUILD_FROM_IMAGE}:${BUILD_TAG_PREFIX}php${PHP_VERSION}${PHP_VARIANT}
ARG  DEBUG
ONBUILD RUN hook onbuild

################################################################################

ADD --link ./rootfs/ /

################################################################################

# https://hypervel.org/docs/deployment
ENV DOCUMENT_ROOT="public"
ENV DISABLE_AUTORUN_GENERATING_INDEX=1
RUN env-default INITIAL_PROJECT "hypervel/hypervel"
RUN env-default APP_INDEX "../artisan"

################################################################################

RUN <<'EOF'
echo 'Install PHP extensions'
[ -z "$DEBUG" ] || set -ex && set -e

env-default PHP_SWOOLE_USE_SHORTNAME 'off'
env-default HTTP_SERVER_PORT "9501"

phpaddmod protobuf swoole

sed -i 's/ --isolated//g' /etc/hooks/onready/*

if has-cmd s6-service; then
    s6-service hypervel longrun '#!/usr/bin/env sh
exec app-exec artisan serve $LARAVEL_SERVE_OPTIONS
'

    s6-service php-fpm unset
    s6-service nginx unset php-fpm
    s6-service nginx depends hypervel

    s6-service horizon unset
    s6-service pulse unset
    s6-service reverb unset
    s6-service scheduler unset
fi

EOF

################################################################################

INCLUDE ./meta

################################################################################

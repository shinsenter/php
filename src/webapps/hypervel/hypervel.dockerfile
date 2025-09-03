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
ARG BUILD_FROM_IMAGE="shinsenter/laravel"
ARG BUILD_TAG_PREFIX=""

ARG PHP_VERSION="8.4"
ARG PHP_VARIANT=""

FROM ${BUILD_FROM_IMAGE}:${BUILD_TAG_PREFIX}php${PHP_VERSION}${PHP_VARIANT}
ARG  DEBUG

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

env-default LARAVEL_AUTO_MIGRATION      '1'
env-default LARAVEL_ENABLE_QUEUE_WORKER '0'
env-default LARAVEL_ENABLE_SCHEDULER    '0'
env-default LARAVEL_ENABLE_HORIZON      '0'
env-default LARAVEL_ENABLE_PULSE        '0'
env-default LARAVEL_ENABLE_REVERB       '0'

env-default PHP_SWOOLE_USE_SHORTNAME 'off'
env-default HTTP_SERVER_PORT "9501"

phpaddmod protobuf swoole

sed -i 's/ --isolated//g' /etc/hooks/onready/*

if has-cmd s6-service; then
    s6-service hypervel longrun '#!/usr/bin/env sh
exec artisan ${LARAVEL_SERVE_COMMAND:-"serve"} $LARAVEL_SERVE_OPTIONS
'

    s6-service php-fpm disable
    s6-service nginx unset php-fpm
    s6-service nginx requires hypervel

    s6-service horizon disable
    s6-service pulse disable
    s6-service reverb disable
    s6-service scheduler disable
fi

EOF

################################################################################
INCLUDE ./meta
ONBUILD RUN hook onbuild

################################################################################

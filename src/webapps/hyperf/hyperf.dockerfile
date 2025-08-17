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

ARG BUILD_FROM_IMAGE=${BUILD_FROM_IMAGE:-shinsenter/phpfpm-nginx}
ARG BUILD_TAG_PREFIX=${BUILD_TAG_PREFIX:-}

ARG PHP_VERSION=${PHP_VERSION:-8.4}
ARG PHP_VARIANT=${PHP_VARIANT:-}

FROM ${BUILD_FROM_IMAGE}:${BUILD_TAG_PREFIX}php${PHP_VERSION}${PHP_VARIANT}
ARG  DEBUG
ONBUILD RUN hook onbuild

################################################################################

ADD --link ./rootfs/ /

################################################################################

# https://hyperf.wiki/3.1/#/en/quick-start/install
ENV DOCUMENT_ROOT=""
ENV DISABLE_AUTORUN_GENERATING_INDEX=1
RUN env-default INITIAL_PROJECT "hyperf/hyperf-skeleton"
RUN env-default APP_INDEX "bin/hyperf.php"

################################################################################

RUN <<'EOF'
echo 'Install PHP extensions'
[ -z "$DEBUG" ] || set -ex && set -e

phpaddmod protobuf swoole

web-cmd hyperf 'php "$(app-index)"'
env-default PHP_SWOOLE_USE_SHORTNAME 'off'

if has-cmd s6-service; then
    s6-service hyperf longrun '#!/usr/bin/env sh
exec app-exec web-do php $(app-index) start
'
    s6-service php-fpm unset
    s6-service nginx unset php-fpm
    s6-service nginx depends hyperf
fi

EOF

################################################################################

INCLUDE ./meta

################################################################################

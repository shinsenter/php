# syntax = ghcr.io/shinsenter/dockerfile-x:v1
################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  SHIN Company <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

# Enable SBOM attestations
# See: https://docs.docker.com/build/attestations/sbom/
ARG BUILDKIT_SBOM_SCAN_CONTEXT=true
ARG BUILDKIT_SBOM_SCAN_STAGE=true

################################################################################

ARG  BUILD_FROM_IMAGE=${BUILD_FROM_IMAGE:-shinsenter/phpfpm-nginx}
ARG  BUILD_TAG_PREFIX=${BUILD_TAG_PREFIX:-}

ARG  PHP_VERSION=${PHP_VERSION:-8.4}
ARG  PHP_VARIANT=${PHP_VARIANT:-}

FROM ${BUILD_FROM_IMAGE}:${BUILD_TAG_PREFIX}php${PHP_VERSION}${PHP_VARIANT}
ONBUILD RUN hook onbuild

################################################################################

ADD  --link ./rootfs/ /
# COPY --link --chmod=755 --from=minio/mc:latest /usr/bin/mc /usr/bin/mc

################################################################################

# https://github.com/coollabsio/coolify
ENV DOCUMENT_ROOT="/public"
ENV DISABLE_AUTORUN_GENERATING_INDEX=1
ENV COOLIFY_ENABLE_HORIZON=1
RUN env-default INITIAL_PROJECT "https://codeload.github.com/coollabsio/coolify/legacy.tar.gz/refs/tags/$(curl --retry 3 --retry-delay 5 -ksLRJ https://api.github.com/repos/coollabsio/coolify/releases/latest | grep "tag_name" | cut -d \" -f 4)?ext=.tar.gz"

# https://coolify.io/docs/installation
ENV PHP_POST_MAX_SIZE="256M"
ENV PHP_UPLOAD_MAX_FILESIZE="256M"
ENV QUEUE_CONNECTION=sync

################################################################################

RUN <<'EOF'
echo 'Configure Coolify'
[ -z "$DEBUG" ] || set -ex && set -e

# install pgsql php extension
phpaddmod pdo_pgsql pgsql

# create Horizon services
if has-cmd s6-service; then
    s6-service horizon longrun '#!/usr/bin/env sh
if is-true $COOLIFY_ENABLE_HORIZON; then
    export APP_PATH="$(app-path)"
    export APP_ROOT="$(app-root)"
    cd $APP_PATH && exec artisan start:horizon
else
    exec s6-svc -Od .
fi
'
fi

# make artisan command alias
web-cmd artisan 'php $(app-path)/artisan'

EOF

################################################################################

INCLUDE ./meta

################################################################################

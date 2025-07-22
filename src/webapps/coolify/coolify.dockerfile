# syntax = ghcr.io/shinsenter/dockerfile-x:v1
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  SHIN Company <shin@shin.company>
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

ADD  --link ./rootfs/ /
# COPY --link --chmod=755 --from=minio/mc:latest /usr/bin/mc /usr/bin/mc

################################################################################

# https://github.com/coollabsio/coolify
ENV DOCUMENT_ROOT="/public"
ENV DISABLE_AUTORUN_GENERATING_INDEX=1
RUN env-default INITIAL_PROJECT "https://codeload.github.com/coollabsio/coolify/legacy.tar.gz/refs/tags/$(curl --retry 3 --retry-delay 5 -ksLRJ https://api.github.com/repos/coollabsio/coolify/releases/latest | grep "tag_name" | cut -d \" -f 4)?ext=.tar.gz"

# https://coolify.io/docs/installation
ENV PHP_POST_MAX_SIZE="256M"
ENV PHP_UPLOAD_MAX_FILESIZE="256M"
ENV QUEUE_CONNECTION="sync"
ENV LARAVEL_ENABLE_HORIZON=1
ENV LARAVEL_ENABLE_SCHEDULER=1

################################################################################

INCLUDE ./meta

################################################################################

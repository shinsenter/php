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

################################################################################
ARG BUILD_FROM_IMAGE="shinsenter/phpfpm-nginx"
ARG BUILD_TAG_PREFIX=""

ARG PHP_VERSION="8.5"
ARG PHP_VARIANT=""

FROM ${BUILD_FROM_IMAGE}:${BUILD_TAG_PREFIX}php${PHP_VERSION}${PHP_VARIANT}
ARG  DEBUG

################################################################################
ADD --link ./rootfs/ /

################################################################################
# https://craftcms.com/docs/5.x/requirements
ENV DOCUMENT_ROOT="web"
ENV DISABLE_AUTORUN_GENERATING_INDEX=1
RUN env-default INITIAL_PROJECT "craftcms/craft"

# Craft recommends 512 MB or more
ENV PHP_MEMORY_LIMIT="512M"

################################################################################
RUN web-cmd craft 'php "$APP_PATH"/craft'

################################################################################
INCLUDE ./meta
ONBUILD RUN hook onbuild

################################################################################

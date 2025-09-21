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
ARG BUILD_FROM_IMAGE="shinsenter/phpfpm-apache"
ARG BUILD_TAG_PREFIX=""

ARG PHP_VERSION="8.4"
ARG PHP_VARIANT=""

FROM ${BUILD_FROM_IMAGE}:${BUILD_TAG_PREFIX}php${PHP_VERSION}${PHP_VARIANT}
ARG  DEBUG

################################################################################
ADD --link ./rootfs/ /

################################################################################
# https://matomo.org/faq/on-premise/installing-matomo/
ENV DOCUMENT_ROOT=""
ENV DISABLE_AUTORUN_GENERATING_INDEX=1
RUN env-default INITIAL_PROJECT "https://codeload.github.com/matomo-org/matomo/legacy.tar.gz/refs/tags/$(download https://api.github.com/repos/matomo-org/matomo/releases/latest | grep "tag_name" | cut -d \" -f 4)?ext=.tar.gz"

################################################################################
INCLUDE ./meta
ONBUILD RUN hook onbuild

################################################################################

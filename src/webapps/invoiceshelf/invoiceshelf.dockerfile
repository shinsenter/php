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
# https://docs.invoiceshelf.com/install/manual.html
ENV LARAVEL_ENABLE_SCHEDULER=1
RUN env-default INITIAL_PROJECT "$(download https://api.github.com/repos/InvoiceShelf/InvoiceShelf/releases/latest | grep "browser_download_url.*InvoiceShelf.*zip" | cut -d \" -f 4)"

################################################################################
INCLUDE ./meta
ONBUILD RUN hook onbuild

################################################################################

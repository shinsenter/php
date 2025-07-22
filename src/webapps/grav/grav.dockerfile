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

ARG BUILD_FROM_IMAGE=${BUILD_FROM_IMAGE:-shinsenter/phpfpm-apache}
ARG BUILD_TAG_PREFIX=${BUILD_TAG_PREFIX:-}

ARG PHP_VERSION=${PHP_VERSION:-8.4}
ARG PHP_VARIANT=${PHP_VARIANT:-}

FROM ${BUILD_FROM_IMAGE}:${BUILD_TAG_PREFIX}php${PHP_VERSION}${PHP_VARIANT}
ARG  DEBUG
ONBUILD RUN hook onbuild

################################################################################

ADD --link ./rootfs/ /

################################################################################

# https://learn.getgrav.org/17/basics/installation
ENV DOCUMENT_ROOT=""
ENV DISABLE_AUTORUN_GENERATING_INDEX=1
ENV COMPOSER_REQUIRES_GIT=1
RUN env-default INITIAL_PROJECT "getgrav/grav"

################################################################################

RUN web-cmd grav   'php $(app-path)/bin/grav'
RUN web-cmd gpm    'php $(app-path)/bin/gpm'
RUN web-cmd plugin 'php $(app-path)/bin/plugin'

################################################################################

INCLUDE ./meta

################################################################################

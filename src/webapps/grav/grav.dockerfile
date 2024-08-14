# syntax = devthefuture/dockerfile-x:1.4.2
################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  SHIN Company <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

# Enable SBOM attestations
# See: https://docs.docker.com/build/attestations/sbom/
ARG  BUILDKIT_SBOM_SCAN_CONTEXT=true

################################################################################

ARG  BUILD_FROM_IMAGE=${BUILD_FROM_IMAGE:-shinsenter/phpfpm-apache}
ARG  BUILD_TAG_PREFIX=${BUILD_TAG_PREFIX:-}

ARG  PHP_VERSION=${PHP_VERSION:-8.4}
ARG  PHP_VARIANT=${PHP_VARIANT:-}

FROM ${BUILD_FROM_IMAGE}:${BUILD_TAG_PREFIX}php${PHP_VERSION}${PHP_VARIANT}
ARG  BUILDKIT_SBOM_SCAN_CONTEXT=true
ONBUILD RUN if has-cmd autorun; then autorun /etc/onbuild.d/; fi

################################################################################

ADD --link ./rootfs/ /

################################################################################

# https://learn.getgrav.org/17/basics/installation
ENV DOCUMENT_ROOT=""
ENV INITIAL_PROJECT="getgrav/grav"
ENV DISABLE_AUTORUN_GENERATING_INDEX=1
ENV COMPOSER_REQUIRES_GIT=1

################################################################################

RUN web-cmd grav   'php $(app-path)/bin/grav'
RUN web-cmd gpm    'php $(app-path)/bin/gpm'
RUN web-cmd plugin 'php $(app-path)/bin/plugin'

################################################################################

INCLUDE ./meta

################################################################################

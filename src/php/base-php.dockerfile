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
# Security backports for end-of-life PHP versions
INCLUDE ./common/php-backports

################################################################################

# php-base is the official PHP image
# rebuilt with the backports when the version has any
FROM php-base
ARG  DEBUG

# set PHP variables
ARG PHP_VERSION="8.5"
ENV PHP_VERSION=${PHP_VERSION//-rc/}

################################################################################
INCLUDE ./common/os-common
INCLUDE ./common/os-crontab
INCLUDE ./common/php-extensions
INCLUDE ./common/php-ini-directives

################################################################################
EXPOSE 22

################################################################################
INCLUDE ./meta

################################################################################

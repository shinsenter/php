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

ARG  BUILD_FROM_IMAGE=${BUILD_FROM_IMAGE:-shinsenter/phpfpm-nginx}
ARG  BUILD_TAG_PREFIX=${BUILD_TAG_PREFIX:-}

ARG  PHP_VERSION=${PHP_VERSION:-8.4}
ARG  PHP_VARIANT=${PHP_VARIANT:-}

FROM ${BUILD_FROM_IMAGE}:${BUILD_TAG_PREFIX}php${PHP_VERSION}${PHP_VARIANT}
ARG  BUILDKIT_SBOM_SCAN_STAGE=true
ONBUILD RUN hook onbuild

################################################################################

ADD --link ./rootfs/ /
ADD https://raw.githubusercontent.com/magento/magento2/2.4/nginx.conf.sample /etc/nginx/custom.d/magento.conf

################################################################################

# https://experienceleague.adobe.com/en/docs/commerce-operations/installation-guide/system-requirements
ENV DOCUMENT_ROOT="/pub"
ENV DISABLE_AUTORUN_GENERATING_INDEX=1
RUN env-default INITIAL_PROJECT "magento/community-edition"

################################################################################

RUN <<'EOF'
echo 'Install PHP extensions'
[ -z "$DEBUG" ] || set -ex && set -e

# install PHP modules
phpaddmod soap sodium sockets xsl

# override nginx config
rm -f /etc/nginx/custom.d/00-ext-*.conf
rm -f /etc/nginx/custom.d/*common.conf
sed -i 's|MAGE_ROOT|APP_PATH|g' /etc/nginx/custom.d/magento.conf
sed -i 's|fastcgi_backend|@php|g' /etc/nginx/custom.d/magento.conf
if grep -qF 'location / {' /etc/nginx/custom.d/magento.conf; then
    sed -i 's#location / {#location @old {#' /etc/nginx/sites-enabled/00-default.conf
fi

# make aliases
web-cmd magento 'php $(app-path)/bin/magento'

EOF

################################################################################

INCLUDE ./meta

################################################################################

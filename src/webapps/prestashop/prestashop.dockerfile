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
ARG BUILD_FROM_IMAGE="shinsenter/phpfpm-apache"
ARG BUILD_TAG_PREFIX=""

ARG PHP_VERSION="8.5"
ARG PHP_VARIANT=""

FROM ${BUILD_FROM_IMAGE}:${BUILD_TAG_PREFIX}php${PHP_VERSION}${PHP_VARIANT}
ARG  DEBUG

################################################################################
ADD --link ./rootfs/ /

################################################################################
# https://devdocs.prestashop-project.org/9/basics/installation/system-requirements/
ENV DOCUMENT_ROOT=""
ENV DISABLE_AUTORUN_GENERATING_INDEX=1

# PrestaShop recommends 512 MB per script
ENV PHP_MEMORY_LIMIT="512M"

################################################################################
RUN <<'EOF'
echo 'Find the latest PrestaShop release'
[ -z "$DEBUG" ] || set -x; set -e

# The API lists releases newest first and mixes in release candidates, so take the first stable one
url="$(download https://api.prestashop-project.org/prestashop | php -r '
foreach (json_decode(stream_get_contents(STDIN), true) as $release) {
    if ($release["stability"] === "stable") {
        echo $release["zip_download_url"];
        break;
    }
}')"
[ -n "$url" ] || { echo 'No PrestaShop download URL'; exit 1; }

# The zip holds prestashop.zip, which hook post-create-project unpacks
env-default INITIAL_PROJECT "$url"
EOF

################################################################################
INCLUDE ./meta
ONBUILD RUN hook onbuild

################################################################################

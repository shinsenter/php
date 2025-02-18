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

ARG  BUILD_FROM_IMAGE=${BUILD_FROM_IMAGE:-shinsenter/phpfpm-apache}
ARG  BUILD_TAG_PREFIX=${BUILD_TAG_PREFIX:-}

ARG  PHP_VERSION=${PHP_VERSION:-8.4}
ARG  PHP_VARIANT=${PHP_VARIANT:-}

FROM ${BUILD_FROM_IMAGE}:${BUILD_TAG_PREFIX}php${PHP_VERSION}${PHP_VARIANT}
ONBUILD RUN hook onbuild

################################################################################

ADD --link ./rootfs/ /

################################################################################

# https://github.com/espocrm/espocrm/tree/stable
ENV DOCUMENT_ROOT="/public"
ENV DISABLE_AUTORUN_GENERATING_INDEX=1

# https://docs.espocrm.com/administration/server-configuration/#setting-up-crontab
ENV ENABLE_CRONTAB=1
ENV CRONTAB_SETTINGS='* * * * * php -f $(app-path)/cron.php &>/dev/null'
ENV ESPOCRM_CONFIG_USE_WEB_SOCKET=0
RUN env-default INITIAL_PROJECT "$(curl --retry 3 --retry-delay 5 -ksLRJ https://api.github.com/repos/espocrm/espocrm/releases/latest | grep "browser_download_url.*EspoCRM.*zip" | cut -d \" -f 4)"

# https://docs.espocrm.com/administration/server-configuration/#php-requirements
ENV PHP_MAX_EXECUTION_TIME="180"
ENV PHP_MAX_INPUT_TIME="180"
ENV PHP_MEMORY_LIMIT="256M"
ENV PHP_POST_MAX_SIZE="50M"
ENV PHP_UPLOAD_MAX_FILESIZE="50M"

################################################################################

RUN <<'EOF'
echo 'Configure EspoCRM'
[ -z "$DEBUG" ] || set -ex && set -e

# install zmq php extension
phpaddmod zmq

# enable preload
# see: https://docs.espocrm.com/administration/performance-tweaking/#preloading
# env-default '# Enable preload to bring a significant performance boost'
# env-default PHP_OPCACHE_PRELOAD '$(app-path)/preload.php'

# enable mod_proxy and mod_proxy_wstunnel
if has-cmd s6-service; then
    a2enmod proxy proxy_wstunnel
fi

# create WebSocket services
if has-cmd s6-service; then
    s6-service espocrm-websocket longrun '#!/usr/bin/env sh
if is-true $ESPOCRM_CONFIG_USE_WEB_SOCKET; then
    export APP_PATH="$(app-path)"
    export APP_ROOT="$(app-root)"
    export ESPOCRM_CONFIG_USE_WEB_SOCKET="true"
    export ESPOCRM_CONFIG_WEB_SOCKET_DEBUG_MODE="$(is-debug && echo 1 || echo 0)"
    export ESPOCRM_CONFIG_WEB_SOCKET_SSL_ALLOW_SELF_SIGNED="true"
    export ESPOCRM_CONFIG_WEB_SOCKET_URL="ws://localhost:8080"
    export ESPOCRM_CONFIG_WEB_SOCKET_ZERO_M_Q_SUBMISSION_DSN="tcp://espocrm-websocket:5555"
    export ESPOCRM_CONFIG_WEB_SOCKET_ZERO_M_Q_SUBSCRIBER_DSN="tcp://*:5555"
    cd $APP_PATH && exec php $APP_PATH/websocket.php
else
    exec s6-svc -Od .
fi
'
fi

EOF

# https://docs.espocrm.com/administration/commands/
RUN web-cmd espocrm '$(app-path)/bin/command'
RUN web-cmd clear_cache 'php $(app-path)/clear_cache.php'
RUN web-cmd rebuild 'php $(app-path)/rebuild.php'

################################################################################

INCLUDE ./meta

################################################################################

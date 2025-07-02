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

# https://laravel.com/docs/master/installation
ENV DOCUMENT_ROOT="/public"
ENV DISABLE_AUTORUN_GENERATING_INDEX=1
RUN env-default INITIAL_PROJECT "laravel/laravel"

################################################################################

RUN <<'EOF'
echo 'Configure Laravel'
[ -z "$DEBUG" ] || set -ex && set -e

# make artisan command alias
web-cmd artisan 'php $(app-path)/artisan'

if has-cmd s6-service; then
    # create queue service
    s6-service queue_worker longrun '#!/usr/bin/env sh
if is-true $LARAVEL_ENABLE_QUEUE_WORKER; then
    export APP_PATH="$(app-path)"
    export APP_ROOT="$(app-root)"
    cd "$APP_PATH" && exec artisan queue:work $LARAVEL_QUEUE_WORKER_OPTIONS
else
    exec s6-svc -Od .
fi
'

    # create scheduler service
    s6-service scheduler longrun '#!/usr/bin/env sh
if is-true $LARAVEL_ENABLE_SCHEDULER; then
    export APP_PATH="$(app-path)"
    export APP_ROOT="$(app-root)"
    cd "$APP_PATH" && exec artisan schedule:work $LARAVEL_SCHEDULER_OPTIONS
else
    exec s6-svc -Od .
fi
'

    # create Pulse service
    s6-service pulse longrun '#!/usr/bin/env sh
if is-true $LARAVEL_ENABLE_PULSE; then
    export APP_PATH="$(app-path)"
    export APP_ROOT="$(app-root)"
    cd "$APP_PATH" && exec artisan pulse:check $LARAVEL_PULSE_OPTIONS
else
    exec s6-svc -Od .
fi
'
    # create Horizon service
    s6-service horizon longrun '#!/usr/bin/env sh
if is-true $LARAVEL_ENABLE_HORIZON; then
    export APP_PATH="$(app-path)"
    export APP_ROOT="$(app-root)"
    cd "$APP_PATH" && exec artisan horizon $LARAVEL_HORIZON_OPTIONS
else
    exec s6-svc -Od .
fi
'
fi

EOF

################################################################################

INCLUDE ./meta

################################################################################

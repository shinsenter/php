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

ARG BUILD_FROM_IMAGE=${BUILD_FROM_IMAGE:-shinsenter/phpfpm-nginx}
ARG BUILD_TAG_PREFIX=${BUILD_TAG_PREFIX:-}

ARG PHP_VERSION=${PHP_VERSION:-8.4}
ARG PHP_VARIANT=${PHP_VARIANT:-}

FROM ${BUILD_FROM_IMAGE}:${BUILD_TAG_PREFIX}php${PHP_VERSION}${PHP_VARIANT}
ARG  DEBUG
ONBUILD RUN hook onbuild

################################################################################

ADD --link ./rootfs/ /

################################################################################

# https://laravel.com/docs/master/installation
ENV DOCUMENT_ROOT="public"
ENV DISABLE_AUTORUN_GENERATING_INDEX=1
RUN env-default INITIAL_PROJECT "laravel/laravel"

################################################################################

RUN <<'EOF'
echo 'Configure Laravel'
[ -z "$DEBUG" ] || set -ex && set -e

env-default LARAVEL_AUTO_MIGRATION      '1'
env-default LARAVEL_ENABLE_QUEUE_WORKER '0'
env-default LARAVEL_ENABLE_SCHEDULER    '1'
env-default LARAVEL_ENABLE_HORIZON      '0'
env-default LARAVEL_ENABLE_PULSE        '0'
env-default LARAVEL_ENABLE_REVERB       '0'

# make artisan command alias
web-cmd artisan 'php "$APP_PATH"/artisan'

if has-cmd s6-service; then
    # create queue service
    s6-service queue_worker longrun '#!/usr/bin/env sh
if is-true "$LARAVEL_ENABLE_QUEUE_WORKER" && artisan queue:work --help &>/dev/null; then
    exec app-exec artisan queue:work $LARAVEL_QUEUE_WORKER_OPTIONS
else
    debug-echo "Service for queue worker is not activated or artisan queue:work is not supported."
    exec s6-svc -Od .
fi
'

    # create scheduler service
    s6-service scheduler longrun '#!/usr/bin/env sh
if is-true "$LARAVEL_ENABLE_SCHEDULER" && artisan schedule:work --help &>/dev/null; then
    exec app-exec artisan schedule:work $LARAVEL_SCHEDULER_OPTIONS
else
    debug-echo "Service for task scheduler is not activated or artisan schedule:work is not supported."
    exec s6-svc -Od .
fi
'

    # create Horizon service
    s6-service horizon longrun '#!/usr/bin/env sh
if is-true "$LARAVEL_ENABLE_HORIZON" && artisan horizon --help &>/dev/null; then
    exec app-exec artisan horizon $LARAVEL_HORIZON_OPTIONS
else
    debug-echo "Service for Laravel Horizon is not activated or artisan horizon is not supported."
    exec s6-svc -Od .
fi
'

    # create Pulse service
    s6-service pulse longrun '#!/usr/bin/env sh
if is-true "$LARAVEL_ENABLE_PULSE" && artisan pulse:check --help &>/dev/null; then
    exec app-exec artisan pulse:check $LARAVEL_PULSE_OPTIONS
else
    debug-echo "Service for Laravel Pulse is not activated or artisan pulse:check is not supported."
    exec s6-svc -Od .
fi
'

    # create Reverb service
    s6-service reverb longrun '#!/usr/bin/env sh
if is-true "$LARAVEL_ENABLE_REVERB" && artisan reverb:start --help &>/dev/null; then
    exec app-exec artisan reverb:start $(is-debug && echo --debug) $LARAVEL_REVERB_OPTIONS
else
    debug-echo "Service for Laravel Reverb is not activated or artisan reverb:start is not supported."
    exec s6-svc -Od .
fi
'
fi

EOF

################################################################################

INCLUDE ./meta

################################################################################

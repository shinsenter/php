################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
# S6 variables
ARG S6_VERSION=""
ARG S6_PATH=""

################################################################################
RUN <<'EOF'
[ -z "$DEBUG" ] || set -ex && set -e

if [ -n "$S6_VERSION" ] && ! has-s6; then
    echo 'Configure s6-overlay'

    SOURCE="https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}"
    FALLBACK_ENTRYPOINT="/init-non-s6"

    # install deps
    if [ ! -x "$(command -v xz)" ] || [ ! -x "$(command -v tar)" ]; then
        APK_PACKAGES="tar xz" \
        APT_PACKAGES="xz-utils" \
        pkg-add
    fi

    # detect system's architecture
    case "$(uname -m)" in
        aarch64 ) S6_ARCH='aarch64' ;;
        arm64   ) S6_ARCH='aarch64' ;;
        armhf   ) S6_ARCH='armhf'   ;;
        arm*    ) S6_ARCH='arm'     ;;
        i4*     ) S6_ARCH='i486'    ;;
        i6*     ) S6_ARCH='i686'    ;;
        riscv64 ) S6_ARCH='riscv64' ;;
        s390*   ) S6_ARCH='s390x'   ;;
        *       ) S6_ARCH='x86_64'  ;;
    esac

    untar() {
        local url="$1"
        local path="${2:-$S6_PATH}/"
        if [ ! -e "$path" ]; then mkdir -p "$path"; fi
        download "$url" | tar Jxp -C "$path"
    }

    # backup existing entrypoint
    if [ -x /init ]; then mv -f /init "$FALLBACK_ENTRYPOINT"; fi

    # and install the right version of s6-overlay
    untar "${SOURCE}/s6-overlay-noarch.tar.xz"
    untar "${SOURCE}/s6-overlay-${S6_ARCH}.tar.xz"
    untar "${SOURCE}/syslogd-overlay-noarch.tar.xz"

    # set s6-overlay default behavior
    if has-cmd env-default; then
        env-default '# Environment variables for s6-overlay'
        env-default S6_BEHAVIOUR_IF_STAGE2_FAILS 2
        env-default S6_CMD_WAIT_FOR_SERVICES 0
        env-default S6_CMD_WAIT_FOR_SERVICES_MAXTIME 0
        env-default S6_KEEP_ENV 1
        env-default S6_KILL_FINISH_MAXTIME 3000
        env-default S6_KILL_GRACETIME 3000
        env-default S6_LOGGING 0
        env-default S6_READ_ONLY_ROOT 0
        env-default S6_SERVICES_GRACETIME 3000
        env-default S6_STAGE2_HOOK 'hook s6-boot'
        env-default S6_VERBOSITY '$(is-debug && echo 2 || echo 0)'
        env-default S6_VERSION "$S6_VERSION"

        env-default '# Keep s6 services alive when $SUPERVISOR_PHP_COMMAND is set'
        env-default KEEP_S6_SERVICES '0'

        env-default '# Add extra service for checking web server'
        env-default DISABLE_ONLIVE_HOOK '1'
    fi

    # create oneshot service for checking web server
    if has-cmd s6-service; then
        s6-service \~verify-server oneshot '#!/usr/bin/env sh
is-true "$DISABLE_ONLIVE_HOOK" && exit 0
wait-for "${HEALTH_CHECK_URL:-http://127.0.0.1}" hook onlive || true
'
    fi

    # check whether to run the legacy entrypoint
    if [ -x /init ] && [ -x "$FALLBACK_ENTRYPOINT" ]; then
        sed -i "s~^exec ~if [ \"\$#\" -gt 0 ]; then is-true \"\$KEEP_S6_SERVICES\" && set -- $FALLBACK_ENTRYPOINT \"\$@\" || exec $FALLBACK_ENTRYPOINT \"\$@\"; fi\n\nexec ~" /init
    fi
fi
EOF

################################################################################
STOPSIGNAL SIGTERM

################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
################################################################################

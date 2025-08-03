################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  SHIN Company <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

# S6 variables
ARG S6_VERSION=${S6_VERSION:-}
ARG S6_PATH=${S6_PATH:-}

################################################################################

RUN <<'EOF'
if ! has-s6 && [ -n "$S6_VERSION" ]; then
    echo 'Configure s6-overlay'
    [ -z "$DEBUG" ] || set -ex && set -e

    SOURCE="https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}"
    FALLBACK_ENTRYPOINT="/usr/local/bin/fallback-entrypoint"

    # install deps
    if [ ! -x "$(command -v xz)" ] || [ ! -x "$(command -v tar)" ]; then
        APK_PACKAGES="tar xz" \
        APT_PACKAGES="xz-utils" \
        pkg-add
    fi

    # backup existing entrypoint
    if [ -x /init ]; then mv -f /init $FALLBACK_ENTRYPOINT; fi

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
        if [ ! -e $path ]; then mkdir -p $path; fi
        download "$url" | tar Jxp -C $path
    }

    # and install the right version of s6-overlay
    untar ${SOURCE}/s6-overlay-noarch.tar.xz
    untar ${SOURCE}/s6-overlay-${S6_ARCH}.tar.xz
    untar ${SOURCE}/syslogd-overlay-noarch.tar.xz

    # fix permissions of /init
    if [ -x /init ]; then
        chown root:root /init
        chmod 4755 /init
    fi

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
        env-default S6_STAGE2_HOOK 'hook s6-onready'
        env-default S6_VERBOSITY '$(is-debug && echo 2 || echo 0)'
        env-default S6_VERSION "$S6_VERSION"
    fi

    # inject legacy entrypoint
    if [ -x $FALLBACK_ENTRYPOINT ]; then
        sed -i "s|^exec |\nif [ \$# -gt 0 ]; then set -- $FALLBACK_ENTRYPOINT \"\$@\"; fi\n\nexec |" /init
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

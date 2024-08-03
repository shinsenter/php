################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  SHIN Company <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

# S6 variables
ARG S6_VERSION=${S6_VERSION:-}
ARG S6_PATH=${S6_PATH:-}

################################################################################

RUN <<'EOF'
echo 'Configure s6-overlay'

if [ -n "$S6_VERSION" ]; then
    SOURCE="https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}"
    FALLBACK_ENTRYPOINT="/usr/local/bin/fallback-entrypoint"

    set -e

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
        curl --retry 2 -ksL "$url" | tar Jxp -C $path
    }

    # and install the right version of s6-overlay
    untar ${SOURCE}/s6-overlay-noarch.tar.xz
    untar ${SOURCE}/s6-overlay-${S6_ARCH}.tar.xz
    untar ${SOURCE}/syslogd-overlay-noarch.tar.xz

    # set s6-overlay default behavior
    if has-cmd env-default; then
        env-default '# Environment variables for s6-overlay'
        env-default S6_BEHAVIOUR_IF_STAGE2_FAILS 2
        env-default S6_CMD_WAIT_FOR_SERVICES_MAXTIME 0
        env-default S6_KEEP_ENV 1
        env-default S6_KILL_FINISH_MAXTIME 3000
        env-default S6_KILL_GRACETIME 3000
        env-default S6_LOGGING 0
        env-default S6_SERVICES_GRACETIME 3000
        env-default S6_VERBOSITY 1
        env-default S6_VERSION $S6_VERSION
    fi

    # inject legacy entrypoint
    if [ -x $FALLBACK_ENTRYPOINT ]; then
        sed -i "s|^exec |\nif [ \$# -gt 0 ]; then set -- $FALLBACK_ENTRYPOINT \"\$@\"; fi\n\nexec |" /init
    fi
fi
EOF

################################################################################

STOPSIGNAL SIGTERM

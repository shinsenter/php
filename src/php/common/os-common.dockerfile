################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
# Set defaults from build arguments
ARG APP_PATH="/var/www/html"
ARG APP_GID="33"
ARG APP_UID="33"
ARG APP_GROUP="www-data"
ARG APP_USER="www-data"

ARG APT_LISTCHANGES_FRONTEND=none
ARG DEBCONF_NOWARNINGS=yes
ARG DEBIAN_FRONTEND=noninteractive
ARG DOCKER_ENTRYPOINT=/usr/local/bin/docker-php-entrypoint

################################################################################
ADD  --link ./common/rootfs/ /

################################################################################
# Install su-exec
COPY --link --from=ghcr.io/shinsenter/su-exec:latest \
    --chown=root:root --chmod=4755 \
    /su-exec /sbin/su-exec

################################################################################
# Set APP_PATH, APP_USER and APP_GROUP
ENV APP_PATH="$APP_PATH"
ENV APP_USER="$APP_USER"
ENV APP_GROUP="$APP_GROUP"

# Set OS variables
ENV ENV="/usr/local/etc/.env"
ENV PATH="/usr/local/aliases:/usr/local/utils:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV PS1="\\u@\\h:\\w\\$ "
ENV PRESQUASH_SCRIPTS="cleanup"

################################################################################
RUN <<'EOF'
sources="/etc/apt/sources.list"
if [ -f "$sources" ]; then
    . /etc/os-release
    if [ "$ID" = "debian" ] && [ "${VERSION_ID%%.*}" -lt 11 ]; then
        debug-echo -w "Patching sources.list for $ID $VERSION_ID"
        sed  -i -e '/stretch-updates/d' \
                -e 's|deb.debian.org/debian|archive.debian.org/debian|g' \
                -e 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' \
                -e 's|^deb\(-src\)\? http|deb\1 [trusted=yes] http|g' \
            $sources
        cat $sources
    fi
fi

pkg-add upgrade
EOF

################################################################################
# Temporary workaround to fix Let's Encrypt CA certificates for old distros
# https://github.com/mlocati/docker-php-extension-installer/pull/450
# https://github.com/mlocati/docker-php-extension-installer/pull/451
# https://github.com/mlocati/docker-php-extension-installer/pull/724
# https://github.com/mlocati/docker-php-extension-installer/pull/737
RUN --mount=type=bind,from=mlocati/php-extension-installer:latest,source=/usr/bin/install-php-extensions,target=/usr/bin/install-php-extensions \
    /usr/bin/install-php-extensions @fix_letsencrypt 2>&1 | grep -vF StandW || true

################################################################################
RUN <<'EOF'
echo 'Configure OS middlewares'
[ -z "$DEBUG" ] || set -ex && set -e

# Install common packages
APK_PACKAGES='findutils ncurses ncurses-terminfo run-parts shadow tar tzdata unzip xz' \
APT_PACKAGES='ncurses-base ncurses-bin vim-tiny xz-utils' \
pkg-add bash ca-certificates coreutils curl htop less openssl procps msmtp

# Setuid bit for some scripts
chmod 4755 "$(command -v autorun)" "$(command -v ownership)" /usr/local/utils/web-*

# Replace sh binary with bash
if has-cmd bash; then
    if has-cmd sh; then
        ln -nsf "$(command -v bash)" "$(command -v sh)"
    else
        ln -nsf "$(command -v bash)" "/bin/sh"
    fi
fi

# Patch nologin binary
if [ ! -e /sbin/nologin ] && has-cmd nologin; then
    ln -nsf "$(command -v nologin)" /sbin/nologin
fi
EOF

################################################################################
RUN <<'EOF'
# Set default debug mode
env-default '# Default debug mode'
env-default DEBUG '0'

# Set default user and group
env-default '# Default user and group'
env-default DEFAULT_GROUP "$APP_USER"
env-default DEFAULT_USER  "$APP_GROUP"

# Add default user and group
ownership "$APP_GROUP" "$APP_GID" "$APP_USER" "$APP_UID"

# Test su-exec
if [ "$(web-do whoami)" != "$APP_USER" ]; then
    echo 'Failed to install su-exec'
    exit 1
fi

# Create default application directory
web-mkdir "$APP_PATH"

EOF

################################################################################
# Run onbuild hook
ONBUILD RUN hook onbuild
RUN DOCKER_NAME="shinsenter/***" hook onbuild

################################################################################
RUN <<'EOF'
echo 'Configure base OS'
[ -z "$DEBUG" ] || set -ex && set -e

# Set aliases for common commands
env-default '# Aliases for common commands'
env-default 'alias ls="ls --color=auto"'
env-default 'alias l1="ls -1"'
env-default 'alias ll="ls -alh"'

# Set OS default settings
env-default '# Environment variables for OS'
env-default APT_LISTCHANGES_FRONTEND $APT_LISTCHANGES_FRONTEND
env-default DEBCONF_NOWARNINGS $DEBCONF_NOWARNINGS
env-default DEBIAN_FRONTEND $DEBIAN_FRONTEND
env-default HISTCONTROL 'ignoreboth'
env-default HISTFILESIZE '2000'
env-default HISTSIZE '1000'
env-default HISTTIMEFORMAT '%F %T '
env-default LANG 'C.UTF-8'
env-default LANGUAGE 'C.UTF-8'
env-default LC_ALL 'C'
env-default PROMPT_COMMAND 'history -a'
env-default TERM 'xterm'
env-default TZ 'UTC'

env-default '# Environment variables for cleanup'
env-default UPGRADE_BEFORE_CLEANUP '1'
env-default CLEANUP_DEV_PACKAGES '1'
env-default CLEANUP_PHPDBG '$(has-cmd php-fpm && echo 1 || echo 0)'

env-default '# Environment variables for sendmail'
env-default SMTP_HOST 'mailpit'
env-default SMTP_PORT '1025'
env-default SMTP_LOG '$(log-path stdout)'
env-default SMTP_FROM ''
env-default SMTP_USER ''
env-default SMTP_PASSWORD ''
env-default SMTP_AUTH ''
env-default SMTP_TLS ''

# Add mail group
if ! getent group mail >/dev/null 2>&1; then
    groupadd mail
fi

# Configure sendmail with msmtp
if has-cmd msmtp-wrapper; then
    if has-cmd sendmail; then
        old="$(command -v sendmail)"
        pkg-del sendmail && \rm -f "$old" || true
    fi

    new="$(command -v msmtp-wrapper)"
    mv -f $new "$(dirname $new)/sendmail"
fi

# Create self-signed certificate
mkcert --days 3652 \
    --cert-file /etc/ssl/site/server.crt \
    --key-file  /etc/ssl/site/server.key \
    localhost 127.0.0.1 ::1

# Backup entrypoint
if [ -f "$DOCKER_ENTRYPOINT" ]; then mv -f "$DOCKER_ENTRYPOINT" /init; fi

EOF

################################################################################
# Add new entrypoint
COPY --chmod=4755 --link ./common/docker-php-entrypoint "$DOCKER_ENTRYPOINT"

################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
################################################################################

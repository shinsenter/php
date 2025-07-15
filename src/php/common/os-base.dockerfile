################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  SHIN Company <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

# set defaults from build arguments
ARG DEBCONF_NOWARNINGS=yes
ARG DEBIAN_FRONTEND=noninteractive
ARG DOCKER_ENTRYPOINT=/usr/local/bin/docker-php-entrypoint

ARG APP_PATH=${APP_PATH:-/var/www/html}
ARG APP_GROUP=${APP_GROUP:-www-data}
ARG APP_USER=${APP_USER:-www-data}

# set APP_PATH, APP_USER and APP_GROUP
ENV APP_PATH="$APP_PATH"
ENV APP_USER="$APP_USER"
ENV APP_GROUP="$APP_GROUP"

# set OS variables
ENV ENV="/etc/.docker-env"
ENV PATH="/usr/local/aliases:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV PS1="\\u@\\h:\\w\\$ "
ENV PRESQUASH_SCRIPTS="cleanup"

################################################################################

ADD --link ./common/rootfs/ /
ONBUILD RUN hook onbuild

################################################################################

RUN <<'EOF'
sources="/etc/apt/sources.list"
if [ -f $sources ]; then
    . /etc/os-release
    if [ "$ID" = "debian" ] && [ "${VERSION_ID%%.*}" -eq 10 ]; then
        debug-echo -i "Patching sources.list for $ID $VERSION_ID"
        sed -i 's|deb.debian.org/debian|archive.debian.org/debian|g' $sources
        sed -i 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' $sources
        cat $sources
    fi
fi
EOF

################################################################################

# Temporary workaround to fix Let's Encrypt CA certificates for old distros
# https://github.com/mlocati/docker-php-extension-installer/pull/450
# https://github.com/mlocati/docker-php-extension-installer/pull/451
# https://github.com/mlocati/docker-php-extension-installer/pull/724
# https://github.com/mlocati/docker-php-extension-installer/pull/737
RUN --mount=type=bind,from=mlocati/php-extension-installer:latest,source=/usr/bin/install-php-extensions,target=/tmp/install-php-extensions \
    /tmp/install-php-extensions @fix_letsencrypt | grep -vF StandWith || true

################################################################################

RUN <<'EOF'
echo 'Configure OS middlewares'
[ -z "$DEBUG" ] || set -ex && set -e

# install common packages
APK_PACKAGES='run-parts shadow tar tzdata unzip xz' \
APT_PACKAGES='procps xz-utils' \
pkg-add bash ca-certificates coreutils curl htop less openssl upgrade

# patch sh binary if bash exists
if has-cmd bash; then
    if has-cmd sh; then
        ln -nsf "$(command -v bash)" "$(command -v sh)"
    else
        ln -nsf "$(command -v bash)" "/bin/sh"
    fi
fi

# patch nologin
if [ ! -e /sbin/nologin ] && has-cmd nologin; then
    ln -nsf "$(command -v nologin)" /sbin/nologin
fi

# check if the group exists
if ! getent group $APP_GROUP >/dev/null 2>&1; then
    addgroup --system $APP_GROUP
fi

# check if the user exists
if ! getent passwd $APP_USER >/dev/null 2>&1; then
    adduser --system --no-create-home --ingroup $APP_GROUP $APP_USER
fi

# install su-exec
SU_EXEC_PATH=/sbin/su-exec
SU_EXEC_URL=https://github.com/songdongsheng/su-exec/releases/download/1.3/su-exec-musl-static
curl -o "$SU_EXEC_PATH" --retry 3 --retry-delay 5 -ksLRJ "$SU_EXEC_URL"
chmod 4755 "$SU_EXEC_PATH"

if ! has-cmd su-exec || [ "$(su-exec $APP_USER:$APP_GROUP whoami)" != "$APP_USER" ]; then
    echo 'Failed to install su-exec'
    exit 1
fi

# setuid bit
chmod 4755 $(which autorun) /usr/local/sbin/web-*

EOF

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
env-default DEBIAN_FRONTEND $DEBIAN_FRONTEND
env-default DEBCONF_NOWARNINGS $DEBCONF_NOWARNINGS
env-default HISTCONTROL 'ignoreboth'
env-default HISTFILESIZE '2000'
env-default HISTSIZE '1000'
env-default LANG 'C.UTF-8'
env-default LANGUAGE 'C.UTF-8'
env-default LC_ALL 'C'
env-default TERM 'xterm'
env-default TZ 'UTC'

env-default '# Environment variables for cleanup'
env-default UPGRADE_BEFORE_CLEANUP '1'
env-default CLEANUP_DEV_PACKAGES '1'
env-default CLEANUP_PHPDBG '$(has-cmd php-fpm && echo 1 || echo 0)'

env-default '# Environment variables for sendmail'
env-default SENDMAIL_SERVER_HOSTNAME 'mailhog'
env-default SENDMAIL_SERVER_PORT '1025'

if [ -z "$(command -v sendmail)" ]; then
    if has-cmd msmtp; then
        env-default SENDMAIL_PATH '$(command -v msmtp) -C /etc/msmtprc -t --read-envelope-from'
    elif has-cmd ssmtp; then
        env-default SENDMAIL_PATH '$(command -v ssmtp) -C /etc/ssmtp/ssmtp.conf -t'
    fi
fi

# create self-signed certificate
mkcert -days 3652 -install \
    -cert-file /etc/ssl/site/server.crt \
    -key-file  /etc/ssl/site/server.key \
    localhost

# backup entrypoint
if [ -f $DOCKER_ENTRYPOINT ]; then mv $DOCKER_ENTRYPOINT /init; fi

# create application directory
web-mkdir $APP_PATH

EOF

################################################################################

# add new entrypoint
COPY --chmod=4755 --link ./common/docker-php-entrypoint $DOCKER_ENTRYPOINT

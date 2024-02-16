################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  Mai Nhut Tan <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

# set defaults from build arguments
ARG DEBCONF_NOWARNINGS=yes
ARG DEBIAN_FRONTEND=noninteractive
ARG DOCKER_ENTRYPOINT=/usr/local/bin/docker-php-entrypoint

ARG APP_PATH=${APP_PATH:-/var/www/html}
ARG APP_GROUP=${APP_GROUP:-www-data}
ARG APP_USER=${APP_USER:-www-data}

# set OS variables
ENV ENV="/etc/docker-envvars"
ENV PATH="/usr/local/aliases:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV PS1="\\u@\\h:\\w\\$ "

# set APP_PATH, APP_USER and APP_GROUP
ENV APP_PATH="$APP_PATH"
ENV APP_USER="$APP_USER"
ENV APP_GROUP="$APP_GROUP"

################################################################################

ADD --link ./common/rootfs/ /

################################################################################

RUN <<'EOF'
echo 'Configure OS middlewares'
set -e

# setuid bit
chmod 4755 /usr/local/bin/web-*

# install common packages
APK_PACKAGES='bash shadow su-exec tar xz' \
APT_PACKAGES='procps xz-utils' \
pkg-add ca-certificates curl htop less openssl upgrade

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

# Check if the group exists
if ! getent group $APP_GROUP >/dev/null 2>&1; then
    addgroup --system $APP_GROUP
fi

# Check if the user exists
if ! getent passwd $APP_USER >/dev/null 2>&1; then
    adduser --system --no-create-home --ingroup $APP_GROUP $APP_USER
fi

EOF

################################################################################

RUN <<'EOF'
echo 'Configure base OS'
set -e

# Set aliases for common commands
env-default '# Aliases for common commands'
env-default 'alias ls="ls --color=auto"'
env-default 'alias l1="ls -1"'
env-default 'alias ll="ls -alh"'

# Set OS default settings
env-default '# Environment variables for OS'
env-default DEBIAN_FRONTEND $DEBIAN_FRONTEND
env-default DEBCONF_NOWARNINGS $DEBCONF_NOWARNINGS
env-default HISTCONTROL 'ignoredups:ignorespace'
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
if [ -f $DOCKER_ENTRYPOINT ]; then
    mv $DOCKER_ENTRYPOINT /init
fi

EOF

################################################################################

# add new entrypoint
COPY --link ./common/docker-php-entrypoint $DOCKER_ENTRYPOINT
RUN chmod 4755 $DOCKER_ENTRYPOINT

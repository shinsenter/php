################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  Mai Nhut Tan <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

# Get IPE script
# See: https://github.com/mlocati/docker-php-extension-installer
ARG IPE_SOURCE=https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions
ADD --link --chmod=755 $IPE_SOURCE /usr/local/bin/

################################################################################

ADD --link ./common/shell-php/ /usr/local/sbin/

################################################################################

RUN <<'EOF'
echo 'Configure PHP extensions'
set -e

# Make alias for php with env
web-cmd root php "$(command -v php)"

if has-cmd install-php-extensions; then
    # Set IPE default settings
    env-default '# Environment variables for IPE'
    env-default IPE_DEBUG '$(is-debug && echo 1 || echo 0)'
    env-default IPE_ASPELL_LANGUAGES 'en'
    env-default IPE_GD_WITHOUTAVIF '1'
    env-default IPE_ICU_EN_ONLY '1'
    env-default IPE_INSTANTCLIENT_BASIC '1'
    env-default IPE_KEEP_SYSPKG_CACHE '0'
    env-default IPE_LZF_BETTERCOMPRESSION '1'

    # Install PHP modules
    phpaddmod @fix_letsencrypt \
        # amqp \
        apcu \
        bcmath \
        # bitset \
        # bz2 \
        calendar \
        # dba \
        # enchant \
        # ev \
        # event \
        exif \
        gd \
        # geos \
        # geospatial \
        gettext \
        # gmagick \
        # gmp \
        # gnupg \
        # grpc \
        # http \
        igbinary \
        # imap \
        # inotify \
        intl \
        # json_post \
        # ldap \
        # luasandbox \
        # lzf \
        # mailparse \
        # memcache \
        # memcached \
        # memprof \
        # mongodb \
        msgpack \
        mysqli \
        # oauth \
        # oci8 \
        # odbc \
        opcache \
        pcntl \
        # pdo_dblib \
        # pdo_firebird \
        pdo_mysql \
        # pdo_odbc \
        pdo_pgsql \
        # pgsql \
        # protobuf \
        # pspell \
        # raphf \
        # rdkafka \
        redis \
        # seasclick \
        # seaslog \
        # shmop \
        # smbclient \
        # snappy \
        # snmp \
        # soap \
        # sockets \
        # ssh2 \
        # swoole \
        # sync \
        # sysvmsg \
        # sysvsem \
        # sysvshm \
        # tidy \
        # timezonedb \
        # uopz \
        # uploadprogress \
        uuid \
        # vld \
        # xdebug \
        # xdiff \
        # xhprof \
        # xmldiff \
        # xmlrpc \
        # xsl \
        yaml \
        zip \
        # zmq \
        # zstd \
    && php -m
fi
EOF

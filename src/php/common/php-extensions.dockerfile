################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  SHIN Company <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

# Get IPE script
# See: https://github.com/mlocati/docker-php-extension-installer
# ARG IPE_SOURCE=https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions
# ADD --link --chmod=755 $IPE_SOURCE /usr/local/bin/

COPY --link --from=mlocati/php-extension-installer:latest --chmod=755 \
    /usr/bin/install-php-extensions \
    /usr/local/bin/

################################################################################

# Add Composer to the PATH
ENV COMPOSER_HOME="/.composer"

################################################################################

ADD --link ./common/shell-php/ /usr/local/sbin/

################################################################################

RUN <<'EOF'
echo 'Install Composer and PHP extensions'
[ -z "$DEBUG" ] || set -ex && set -e

# Set Composer default settings
env-default '# Environment variables for Composer'
env-default COMPOSER_ALLOW_SUPERUSER  '1'
env-default COMPOSER_ALLOW_XDEBUG     '$(is-debug && echo 1 || echo 0)'
env-default COMPOSER_FUND             '0'
env-default COMPOSER_HTACCESS_PROTECT '1'
env-default COMPOSER_MEMORY_LIMIT     '-1'
env-default COMPOSER_NO_AUDIT         '1'
env-default COMPOSER_NO_INTERACTION   '1'
env-default COMPOSER_PROCESS_TIMEOUT  '0'

# Set IPE default settings
env-default '# Environment variables for IPE'
env-default IPE_DEBUG                 '$(is-debug && echo 1 || echo 0)'
env-default IPE_ASPELL_LANGUAGES      'en'
env-default IPE_GD_WITHOUTAVIF        '1'
env-default IPE_ICU_EN_ONLY           '1'
env-default IPE_INSTANTCLIENT_BASIC   '1'
env-default IPE_KEEP_SYSPKG_CACHE     '0'
env-default IPE_LZF_BETTERCOMPRESSION '1'

# Install Composer and popular PHP modules
phpaddmod @composer \
    # amqp \
    apcu \
    # apcu_bc \
    # ast \
    bcmath \
    # bitset \
    # blackfire \
    # brotli \
    # bz2 \
    calendar \
    # cassandra \
    # cmark \
    # csv \
    # dba \
    # ddtrace \
    # decimal \
    # ds \
    # ecma_intl \
    # enchant \
    # ev \
    # event \
    # excimer \
    exif \
    # ffi \
    # ftp \
    gd \
    # gearman \
    # geoip \
    # geos \
    # geospatial \
    gettext \
    # gmagick \
    # gmp \
    # gnupg \
    # grpc \
    # http \
    igbinary \
    # imagick \
    # imap \
    # inotify \
    # interbase \
    intl \
    # ion \
    # ioncube_loader \
    # jsmin \
    # json_post \
    # jsonpath \
    # ldap \
    # luasandbox \
    # lz4 \
    # lzf \
    # mailparse \
    # maxminddb \
    # mcrypt \
    # md4c \
    # memcache \
    # memcached \
    # memprof \
    # mongo \
    # mongodb \
    # mosquitto \
    msgpack \
    # mssql \
    # mysql \
    mysqli \
    # newrelic \
    # nsq \
    # oauth \
    # oci8 \
    # odbc \
    opcache \
    # opencensus \
    # openswoole \
    # opentelemetry \
    # parallel \
    # parle \
    pcntl \
    # pcov \
    # pdo_dblib \
    # pdo_firebird \
    pdo_mysql \
    # pdo_oci \
    # pdo_odbc \
    pdo_pgsql \
    # pdo_sqlsrv \
    pgsql \
    # phalcon \
    # php_trie \
    # phpy \
    # pkcs11 \
    # pq \
    # propro \
    # protobuf \
    # pspell \
    # psr \
    # pthreads \
    # raphf \
    # rdkafka \
    # recode \
    redis \
    # relay \
    # saxon \
    # seasclick \
    # seaslog \
    # shmop \
    # simdjson \
    # smbclient \
    # snappy \
    # snmp \
    # snuffleupagus \
    # soap \
    # sockets \
    sodium \
    # solr \
    # sourceguardian \
    # spx \
    # sqlsrv \
    # ssh2 \
    # stomp \
    # swoole \
    # sybase_ct \
    # sync \
    # sysvmsg \
    # sysvsem \
    # sysvshm \
    # tensor \
    # tideways \
    tidy \
    # timezonedb \
    # translit \
    # uopz \
    # uploadprogress \
    uuid \
    # uv \
    # vips \
    # vld \
    # wddx \
    # wikidiff2 \
    # xdebug \
    # xdiff \
    # xhprof \
    # xlswriter \
    # xmldiff \
    # xmlrpc \
    # xpass \
    # xsl \
    # yac \
    yaml \
    # yar \
    # zephir_parser \
    zip \
    # zmq \
    # zookeeper \
    # zstd \
    && php -m && composer -V

# Make alias for some commands
has-cmd php      && web-cmd root php      "$(command -v php)"
has-cmd php-fpm  && web-cmd root php-fpm  "$(command -v php-fpm)"
has-cmd pecl     && web-cmd root pecl     "$(command -v pecl)"
has-cmd composer && web-cmd root composer "$(command -v composer)"

EOF

################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
################################################################################

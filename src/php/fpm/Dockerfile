# This pipeline will keep image size as small as possible.
################################################################################

# base image and platform
# FROM ${BASE_IMAGE:-shinsenter/php-cli:latest} as base
FROM php-cli as base

ENV PHP_DATE_TIMEZONE=${TZ:-UTC}
ENV PHP_DISPLAY_ERRORS=On
ENV PHP_ERROR_REPORTING="E_ALL & ~E_DEPRECATED & ~E_STRICT"
ENV PHP_MAX_EXECUTION_TIME=99
ENV PHP_MEMORY_LIMIT=256M
ENV PHP_PM_CONTROL=dynamic
ENV PHP_PM_MAX_CHILDREN=20
ENV PHP_PM_MAX_SPARE_SERVERS=3
ENV PHP_PM_MIN_SPARE_SERVERS=1
ENV PHP_PM_START_SERVERS=2
ENV PHP_POOL_NAME=www
ENV PHP_POST_MAX_SIZE=100M
ENV PHP_UPLOAD_MAX_FILE_SIZE=100M

# installs php-fpm
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        php${PHP_VERSION}-fpm \
    && mv -f  /etc/php/${PHP_VERSION}/fpm /etc/php/fpm \
    && ln -sf /etc/php/fpm /etc/php/${PHP_VERSION}/fpm \
    && sed -i -e 's/\[www\]/\[$\{PHP_POOL_NAME\}]/g' /etc/php/fpm/pool.d/www.conf \
    \
    && apt-get -y autoremove && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

################################################################################

# main image
FROM base

# adds config files
ADD etc/ /etc/

EXPOSE 9000

################################################################################
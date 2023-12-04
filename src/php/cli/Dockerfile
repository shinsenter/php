# This file belongs to the project https://code.shin.company/php
# Author:  Shin <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ARG BASE_IMAGE=shinsenter/s6-ubuntu:latest

################################################################################

# base image
FROM ${BASE_IMAGE}

ARG PHP_BUILD_DEPS="gnupg2 apt-utils"
ARG PHP_PPA_KEY="4F4EA0AAE5267A6C"
ARG PHP_PPA_URL="http://ppa.launchpad.net/ondrej/php/ubuntu"
ARG PHP_MODULES="/usr/src/php${PHP_VERSION}.txt"
ARG PHP_VERSION=8.3
ARG COMPOSER_INSTALLER="https://getcomposer.org/installer"
ARG COMPOSER_SCRIPT="/tmp/composer-setup.php"
ARG COMPOSER_BIN="/usr/bin/composer"
ARG COMPOSER_VENDOR_DIR=vendor

ENV PHP_VERSION=${PHP_VERSION}
ADD php${PHP_VERSION}.txt $PHP_MODULES

# composer settings
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_HOME=/composer
ENV COMPOSER_HTACCESS_PROTECT=1
ENV COMPOSER_MAX_PARALLEL_HTTP=8
ENV COMPOSER_CREATE_OPTIONS="--ansi --no-interaction --no-secure-http"
ENV COMPOSER_INSTALL_OPTIONS="--ansi --no-interaction --optimize-autoloader"
ENV COMPOSER_REQUIRE_OPTIONS="--ansi --no-interaction --optimize-autoloader --sort-packages"

################################################################################

# adds config files
ADD root/ /

# installs PHP and Composer
RUN echo "Installing PHP ${PHP_VERSION}" \
    && apt-update \
    && apt-install $PHP_BUILD_DEPS less sudo unzip \
    && apt-deb ppa-php $PHP_PPA_URL $PHP_PPA_KEY \
    && phpaddmod $(cat $PHP_MODULES) \
    && swap-dir /etc/php/${PHP_VERSION}/cli /etc/php/cli \
    \
    # makes symlinks
    && ln -fs /usr/bin/php       /usr/local/bin/php \
    && ln -sf /etc/php/cli       /usr/local/etc/php \
    && ln -sf /usr/bin/phpaddmod /usr/sbin/docker-php-ext-install \
    && ln -sf /usr/bin/phpenmod  /usr/sbin/docker-php-ext-enable \
    && ln -sf /usr/bin/phpdelmod /usr/sbin/docker-php-ext-remove \
    && ln -sf /usr/bin/phpdismod /usr/sbin/docker-php-ext-disable \
    \
    # installs composer
    && mkdir -p ${COMPOSER_HOME} \
    && php -r "copy('${COMPOSER_INSTALLER}', '${COMPOSER_SCRIPT}');" \
    && php $COMPOSER_SCRIPT --install-dir=/usr/bin --filename=composer \
    && chmod +xr ${COMPOSER_BIN} \
    \
    # cleanup
    && apt-upgrade -uq \
    && cleanup $PHP_BUILD_DEPS

# sets the working directory
WORKDIR $WEBHOME

# sets default entrypoint and command
ENTRYPOINT []
CMD ["/usr/bin/php", "-a"]

################################################################################

ENV PATH=${PATH}:${COMPOSER_HOME}/${COMPOSER_VENDOR_DIR}/bin
ENV PHP_CONF_DIR=/etc/php/cli/conf.d
ENV PHP_INI_DIR=/etc/php/cli

################################################################################
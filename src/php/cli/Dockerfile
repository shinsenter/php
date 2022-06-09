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
ARG PHP_VERSION="8.1"

ENV PHP_VERSION=${PHP_VERSION}
ADD php${PHP_VERSION}.txt $PHP_MODULES

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
    && php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');" \
    && php /tmp/composer-setup.php --install-dir=/usr/bin --filename=composer \
    && chmod +xr /usr/bin/composer \
    \
    # cleanup
    && apt-upgrade -uq \
    && cleanup $PHP_BUILD_DEPS

# sets the working directory
# WORKDIR $WEBHOME

# sets default entrypoint and command
ENTRYPOINT []
CMD ["/usr/bin/php", "-a"]

################################################################################

# adds composer settings
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_HOME=/composer
ENV COMPOSER_MAX_PARALLEL_HTTP=32
ENV PATH=/composer/vendor/bin:$PATH
ENV PHP_CONF_DIR=/etc/php/cli/conf.d
ENV PHP_INI_DIR=/etc/php/cli

################################################################################
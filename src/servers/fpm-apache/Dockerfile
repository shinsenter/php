# This file belongs to the project https://code.shin.company/php
# Author:  Shin <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ARG BASE_IMAGE=shinsenter/php
ARG PHP_VERSION=8.3

################################################################################

# base image
FROM ${BASE_IMAGE}:${PHP_VERSION}-fpm

ARG APACHE_BUILD_DEPS="gnupg2 apt-utils"
ARG APACHE_PPA_KEY="4F4EA0AAE5267A6C"
ARG APACHE_PPA_URL="http://ppa.launchpadcontent.net/ondrej/apache2/ubuntu"

################################################################################

# installs apache
RUN echo "Installing Apache" \
    && apt-update \
    && apt-install $APACHE_BUILD_DEPS \
    && apt-deb ppa-apache ${APACHE_PPA_URL} ${APACHE_PPA_KEY} \
    && apt-install apache2 && disable apache2 \
    && echo "ServerName localhost" >>/etc/apache2/apache2.conf \
    && sed  -i 's/LogFormat "%h %l %u %t \\\"%r\\\" %>s %O \\\"/LogFormat "%a %l %u %t \\\"%r\\\" %>s %O \\\"/' /etc/apache2/apache2.conf \
    && grep -lr "unix" /etc/apache2/ | xargs -I {} sed -i 's#unix:.*fpm.sock#unix:${PHPFPM_SOCK_PATH}#g' {} \
    && echo >>/etc/apache2/envvars \
    && echo "export DOCUMENT_ROOT=\"\${WEBHOME}\${APACHE_DOCUMENT_ROOT}\"" >>/etc/apache2/envvars \
    && echo "export APACHE_RUN_USER=\${WEBUSER}" >>/etc/apache2/envvars \
    && echo "export APACHE_RUN_GROUP=\${WEBGROUP}" >>/etc/apache2/envvars \
    \
    # modifies Apache modules
    && a2dismod \
        mpm_prefork mpm_worker \
    && a2enmod \
        actions autoindex brotli cache deflate expires headers http2 \
        mpm_event proxy proxy_fcgi remoteip rewrite setenvif ssl unique_id \
    && a2enconf php* \
    \
    # cleanup
    && rm -rf /var/log/apache2 ${WEBHOME}/*.html \
    && apt-upgrade -uq \
    && cleanup $APACHE_BUILD_DEPS

# adds config files
ADD root/ /

# sets the working directory
# WORKDIR $WEBHOME

# exposes ports
EXPOSE 80
EXPOSE 443
EXPOSE 443/udp

# sets default entrypoint
ENTRYPOINT ["/init"]

################################################################################

# sets env variables
ENV APACHE_DOCUMENT_ROOT=""
ENV APACHE_MAX_CONNECTIONS_PER_CHILD=0
ENV APACHE_MAX_REQUEST_WORKERS=150
ENV APACHE_MAX_SPARE_THREADS=75
ENV APACHE_MIN_SPARE_THREADS=10
ENV APACHE_START_SERVERS=2
ENV APACHE_THREAD_LIMIT=64
ENV APACHE_THREADS_PER_CHILD=25

# automatically create index.php
ENV AUTO_CREATE_INDEX_FILE="false"

################################################################################

LABEL traefik.enable=true
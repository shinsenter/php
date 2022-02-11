# This pipeline will keep image size as small as possible.
################################################################################

# base image and platform
# FROM ${BASE_IMAGE:-shinsenter/php-fpm:latest} as base
FROM php-fpm as base

ENV APACHE_DOCUMENT_ROOT=${APACHE_DOCUMENT_ROOT:-$WEBHOME}
ENV APACHE_MAX_CONNECTIONS_PER_CHILD=0
ENV APACHE_MAX_REQUEST_WORKERS=150
ENV APACHE_MAX_SPARE_THREADS=75
ENV APACHE_MIN_SPARE_THREADS=10
ENV APACHE_RUN_GROUP=webgroup
ENV APACHE_RUN_USER=webuser
ENV APACHE_START_SERVERS=2
ENV APACHE_THREAD_LIMIT=64
ENV APACHE_THREADS_PER_CHILD=25
ENV MSMTP_RELAY_SERVER_HOSTNAME=mailhog
ENV MSMTP_RELAY_SERVER_PORT=1025

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        msmtp \
        msmtp-mta \
        apache2 \
    \
    && a2enmod actions autoindex deflate headers http2 proxy proxy_fcgi remoteip rewrite setenvif ssl unique_id \
    && service apache2 stop && update-rc.d apache2 disable \
    && echo "export APACHE_RUN_USER=${APACHE_RUN_USER}" >>/etc/apache2/envvars \
    && echo "export APACHE_RUN_GROUP=${APACHE_RUN_GROUP}" >>/etc/apache2/envvars \
    && echo "ServerName localhost" >>/etc/apache2/apache2.conf \
    && sed -i 's/LogFormat "%h %l %u %t \\\"%r\\\" %>s %O \\\"/LogFormat "%a %l %u %t \\\"%r\\\" %>s %O \\\"/' /etc/apache2/apache2.conf \
    && ln -sf /dev/stdout /var/log/apache2/access.log \
    && ln -sf /dev/stdout /var/log/apache2/other_vhosts_access.log \
    && ln -sf /dev/stderr /var/log/apache2/error.log \
    \
    && apt-get -y autoremove && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

################################################################################

# main image
FROM base

# adds config files
ADD etc/ /etc/

EXPOSE 80
EXPOSE 443
EXPOSE 443/udp

################################################################################
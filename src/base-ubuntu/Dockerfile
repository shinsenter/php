# This file is the work of https://github.com/shinsenter/php
################################################################################

ARG BASE_IMAGE=ubuntu:latest
ARG S6_BASE_IMAGE=shinsenter/s6-overlay
ARG S6_VERSION=latest

################################################################################

FROM ${S6_BASE_IMAGE}:latest as source

################################################################################

# prepares base image
FROM ${BASE_IMAGE} as base

# disable frontend
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm

# adds binaries
ADD root/ /

# updates packages
RUN echo "🤖 Updating packages..."
RUN apt-update
RUN apt-install ca-certificates

# sets GID and UID
ENV PUID=9999
ENV PGID=9999
ENV WEBHOME="/var/www/html"

# adds user and group
RUN echo "🤖 Creating webuser and webgroup..."
RUN groupadd -r -g $PGID webgroup
RUN useradd  -r -g $PGID -u $PUID -d $WEBHOME -s /usr/bin/bash --no-log-init webuser

# cleanup
RUN apt-cleanup

################################################################################

# the main image
FROM scratch

# copies from from build stage
COPY --from=base / /

# copies s6-overlay from source
COPY --from=source / /
ENTRYPOINT ["/init"]

################################################################################

# sets GID and UID
ENV PUID=9999
ENV PGID=9999
ENV WEBHOME="/var/www/html"

# adds OS variables
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8
ENV LC_ALL=C
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV TERM=xterm

# S6 variables
ARG S6_VERSION
ENV S6_VERSION=$S6_VERSION
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=600000
ENV S6_GLOBAL_PATH=/command:$PATH
ENV S6_KILL_FINISH_MAXTIME=3000
ENV S6_KILL_GRACETIME=3000
ENV S6_SERVICES_GRACETIME=3000

################################################################################

LABEL category="os"
LABEL category="base"

################################################################################
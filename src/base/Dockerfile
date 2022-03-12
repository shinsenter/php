# This file is the work of https://github.com/shinsenter/php
################################################################################

ARG BASE_IMAGE=ubuntu:latest

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

################################################################################

# extracts s6-overlay bundles into a temporary image
FROM base as source

# sets version for s6 overlay
ARG S6_VERSION
ARG S6_SRC_DEP="wget xz-utils"
ARG S6_SRC_URL="https://github.com/just-containers/s6-overlay/releases/download"

# checks build argument
RUN if [ -z "$S6_VERSION" ]; then \
        echo "Please set S6_VERSION build argument."; exit 1; \
    fi

# adds build dependencies
RUN apt-update && apt-install $S6_SRC_DEP
RUN touch /etc/wgetrc \
    && echo 'ca_certificate=/etc/ssl/certs/ca-certificates.crt' >>/etc/wgetrc

# detect system arch then select the right version of s6
RUN SYS_ARCH=$(uname -m); \
    case "$SYS_ARCH" in \
        aarch64 ) export S6_ARCH='aarch64' ;; \
        arm*    ) export S6_ARCH='armhf'   ;; \
        i4+     ) export S6_ARCH='i486'    ;; \
        i6+     ) export S6_ARCH='i686'    ;; \
        riscv64 ) export S6_ARCH='riscv64' ;; \
        s390*   ) export S6_ARCH='s390x'   ;; \
        *       ) export S6_ARCH='x86_64'  ;; \
    esac; \
    \
    # adds s6 overlay
    echo "⬇️ Downloading s6 overlay:${S6_ARCH}-${S6_VERSION} for ${SYS_ARCH}..." \
    && S6_DIR=/usr/src/s6/ \
    && mkdir -p $S6_DIR \
    && untar (){ \
        echo "  ⏬ Downloading $1"; \
        wget -O- $1 | tar Jxp -C ${2:-"$S6_DIR"}; \
    } \
    && untar ${S6_SRC_URL}/${S6_VERSION}/s6-overlay-noarch.tar.xz \
    && untar ${S6_SRC_URL}/${S6_VERSION}/s6-overlay-${S6_ARCH}.tar.xz \
    && du -sh $S6_DIR

################################################################################

# the build stage
FROM base as build

# copies s6-overlay from source
COPY --from=source /usr/src/s6/ /

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
COPY --from=build / /
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

ARG   BUILD_NUMBER
LABEL build_number="$BUILD_NUMBER"
LABEL maintainer="shin@shin.company"
LABEL publisher="https://hub.docker.com/u/shinsenter"

# This pipeline will keep image size as small as possible.
################################################################################

ARG BASE_IMAGE=ubuntu:latest

# base image and platform
FROM ${BASE_IMAGE} as base

# adds labels
LABEL publisher="shinsenter"
LABEL maintainer="admin@appseeds.net"

# sets environment variables for OS
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm
ENV LC_ALL=C
ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8
ENV TZ=UTC

# common methods
ADD usr/ /usr/

################################################################################

# extracts s6-overlay bundles into a temporary image
FROM base as source

# sets version for s6 overlay
ARG S6_SRC="http://github.com/just-containers/s6-overlay/releases/download"
ARG S6_VERSION="3.0.0.2"
ARG S6_BUILD_DEP="ca-certificates wget xz-utils"

RUN SYS_ARCH=$(uname -m); \
    # detect system arch then select the right version of s6
    case "$SYS_ARCH" in \
        aarch64 ) export S6_ARCH='aarch64' ;; \
        arm*    ) export S6_ARCH='armhf'   ;; \
        i4+     ) export S6_ARCH='i486'    ;; \
        i6+     ) export S6_ARCH='i686'    ;; \
        riscv64 ) export S6_ARCH='riscv64' ;; \
        s390*   ) export S6_ARCH='s390x'   ;; \
        *       ) export S6_ARCH='x86_64'  ;; \
    esac; \
    apt-update && apt-install $S6_BUILD_DEP \
    \
    # adds s6 overlay
    && echo "Downloading S6 $S6_ARCH variation for $SYS_ARCH..." \
    && mkdir -p /usr/src/s6 \
    && untar (){\
        echo "Downloading $1";\
        wget -O- $1 2>/dev/null | tar Jxp -v -C ${2:-/usr/src/s6/}; \
       } \
    && untar ${S6_SRC}/v${S6_VERSION}/s6-overlay-noarch-${S6_VERSION}.tar.xz \
    && untar ${S6_SRC}/v${S6_VERSION}/s6-overlay-${S6_ARCH}-${S6_VERSION}.tar.xz

################################################################################

# main image
FROM base

# copies s6-overlay from source
ENV S6_GLOBAL_PATH=/command:/usr/local/bin:/usr/bin:/bin
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=60000
ENV S6_SERVICES_GRACETIME=3000
ENV S6_KILL_GRACETIME=3000
ENV S6_KILL_FINISH_MAXTIME=3000
COPY --from=source /usr/src/s6/ /

# sets environment variables for user
ENV PUID=9999
ENV PGID=9999
ENV HOME=/root
ENV WEBHOME="/var/www/html"
ENV FIX_WEBHOME_PERMISSION=false

# adds user and group
RUN groupadd -r -g $PGID webgroup
RUN useradd  -r -g $PGID -u $PUID -d $WEBHOME \
                -s /usr/bin/bash --no-log-init webuser

# adds other config files
ADD etc/ /etc/

# starts s6
WORKDIR     $WEBHOME
ENTRYPOINT  ["/init"]

################################################################################
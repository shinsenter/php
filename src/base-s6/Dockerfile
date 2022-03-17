# This file is the work of https://github.com/shinsenter/php
################################################################################

ARG BASE_IMAGE=ubuntu:latest

################################################################################

# prepares base image
FROM ${BASE_IMAGE} as build

# sets version for s6 overlay
ARG S6_DIR=/usr/src/s6/
ARG S6_SRC_DEP="xz-utils wget"
ARG S6_SRC_URL="https://github.com/just-containers/s6-overlay/releases/download"
ARG S6_VERSION

# disable frontend
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm

# checks build argument
RUN if [ -z "$S6_VERSION" ]; then \
        echo "Please set S6_VERSION build argument."; exit 1; \
    fi

# adds build dependencies
RUN apt-get update -y
RUN apt-get install -y $S6_SRC_DEP --no-install-recommends --no-install-suggests

# detect system arch then select the right version of s6
RUN export SYS_ARCH=$(uname -m); \
    case "$SYS_ARCH" in \
        aarch64 ) export S6_ARCH='aarch64' ;; \
        arm     ) export S6_ARCH='arm'     ;; \
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
    && mkdir -p $S6_DIR \
    && untar (){ \
        echo "  ⏬ Downloading $1"; \
        wget --no-check-certificate -O- $1 | tar Jxp -C ${2:-"$S6_DIR"}; \
    } \
    && untar ${S6_SRC_URL}/${S6_VERSION}/s6-overlay-noarch.tar.xz \
    && untar ${S6_SRC_URL}/${S6_VERSION}/s6-overlay-${S6_ARCH}.tar.xz \
    && du -sh $S6_DIR

################################################################################

# the main image
FROM scratch

# copies from from build stage
COPY --from=build /usr/src/s6/ /
ENTRYPOINT ["/init"]

################################################################################
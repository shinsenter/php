# syntax=docker/dockerfile:1
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
# dockerfile-x from the ./upstream submodule, with patched Go modules.
# build.sh squashes the result into one layer. Context: this folder.
ARG ORAS_VERSION=1.4.0

################################################################################
# Frontend and oras, cross-compiled on the build platform
################################################################################
FROM --platform=$BUILDPLATFORM golang:alpine AS go
ARG TARGETARCH
ARG ORAS_VERSION
ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=$TARGETARCH

RUN apk add --no-cache git upx \
    && git clone -q --depth 1 --branch "v$ORAS_VERSION" \
        https://github.com/oras-project/oras.git /oras

WORKDIR /oras
RUN --mount=type=bind,source=patches,target=/patches \
    /patches/bump-go-deps.sh \
    && go build -trimpath -ldflags='-s -w' -o /out/oras ./cmd/oras

WORKDIR /app
COPY upstream/go.mod upstream/go.sum upstream/main.go ./
COPY upstream/vendor ./vendor
COPY upstream/pkg ./pkg
COPY patches/proxy_containers.go ./pkg/dtp/
RUN --mount=type=bind,source=patches,target=/patches \
    /patches/bump-go-deps.sh \
    && go build -mod=vendor -trimpath -ldflags='-s -w' \
        -o /out/dockerfile-x-frontend .

# Pack both Go binaries, the stage is not shipped so upx adds nothing to the image
RUN upx --best --lzma -q /out/oras /out/dockerfile-x-frontend

################################################################################
# CLI (ncc bundle packed by pkg), same steps as upstream
################################################################################
FROM node:18 AS cli
ARG TARGETARCH

WORKDIR /app
COPY upstream/.yarnrc.yml upstream/yarn.lock upstream/package.json ./
COPY upstream/.yarn .yarn
RUN --mount=type=bind,source=patches,target=/patches \
    /patches/bump-yarn-deps.sh \
    && yarn fetch

COPY upstream/src ./src
COPY upstream/index.js upstream/package.json ./
RUN case "$TARGETARCH" in \
        amd64) arch=x64 ;; \
        arm)   arch=armv7 ;; \
        *)     arch="$TARGETARCH" ;; \
    esac \
    && yarn build:ncc \
    && yarn pkg -t "node18-linuxstatic-$arch" \
        -o /out/dockerfile-x --compress=GZip ./dist/index.js

################################################################################
# Final image
################################################################################
FROM alpine:3
LABEL moby.buildkit.frontend.caps="moby.buildkit.frontend.inputs,moby.buildkit.frontend.subrequests,moby.buildkit.frontend.contexts" \
      org.opencontainers.image.source="https://codeberg.org/devthefuture/dockerfile-x" \
      org.opencontainers.image.version="1.6.0"

RUN apk upgrade --no-cache \
    && apk add --no-cache ca-certificates \
    && adduser -D -u 1000 dockerfile-x \
    && mkdir /workspace \
    && chown 1000:1000 /workspace \
    && rm -rf /usr/share/man /usr/share/doc /usr/share/info \
        /usr/share/bash-completion \
        /var/cache/apk/* /tmp/*

COPY --from=go /out/ /usr/local/bin/
COPY --from=cli /out/ /usr/local/bin/

ENV DOCKERFILEX_TMPDIR=/workspace
USER 1000
WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/dockerfile-x-frontend"]

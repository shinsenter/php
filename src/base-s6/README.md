# shinsenter/s6-overlay

The images in this repository contain only the unpacked s6-overlay as a multi-platform build stage.

https://hub.docker.com/r/shinsenter/s6-overlay

[![Docker Pulls](https://img.shields.io/docker/pulls/shinsenter/s6-overlay)](https://hub.docker.com/r/shinsenter/s6-overlay) [![Docker Image Size](https://img.shields.io/docker/image-size/shinsenter/s6-overlay/latest?label=shinsenter%2Fs6-overlay)](https://hub.docker.com/r/shinsenter/s6-overlay/tags)

* * *

## About this project

The images in this repository contain only the unpacked [s6-overlay](https://github.com/just-containers/s6-overlay) as a multi-platform and reusable build stage.

The s6-overlay was built specifically for the lifecycle of containers, giving you a more accurate way of bringing containers down and monitoring their health.

## Usage

This repository is not intended to be used directly, but rather consumed in other Dockerfiles as a multi-platform and reusable build stage.

```Dockerfile
FROM ubuntu

# adds file from the shinsenter/s6-overlay image
COPY --from=shinsenter/s6-overlay / /
ENTRYPOINT ["/init"]

# runs other commands
RUN ...
```

## Supported platforms

This repository uses multi-platform images via Docker manifests. Currently, the supported architectures are:

- linux/amd64
- linux/arm/v7
- linux/arm64
- linux/ppc64le
- linux/riscv64
- linux/s390x

You do not need to use a platform-specific tag (although you can), Docker will automatically choose the appropriate architecture.
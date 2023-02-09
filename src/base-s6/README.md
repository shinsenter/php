# shinsenter/s6-overlay

🗂 The images in this repository contain unpacked s6-overlay v3 as a multi-platform build stage.

> 🔗 https://docker.shin.company/s6-overlay

[![Docker Pulls](https://img.shields.io/docker/pulls/shinsenter/s6-overlay)](https://docker.shin.company/s6-overlay) [![Docker Image Size](https://img.shields.io/docker/image-size/shinsenter/s6-overlay/latest?label=shinsenter%2Fs6-overlay)](https://docker.shin.company/s6-overlay)

* * *

## About this project

Are you tired of using clunky and outdated init systems for your containers? Look no further than this repository, where you'll find images containing only the latest version of [s6-overlay v3](https://github.com/just-containers/s6-overlay). This powerful tool was built specifically for the lifecycle of containers, giving you a more accurate way of bringing containers down and monitoring their health.

But that's not all - these images are actively maintained, ensuring that you're always using the most up-to-date version of s6-overlay. Upgrade your Docker containers with ease.

## Usage

This repository is not just a one-trick pony - it's intended to be used as a multi-platform and reusable build stage in other Dockerfiles.

```Dockerfile
FROM ubuntu:latest

# adds file from the shinsenter/s6-overlay image
COPY --from=shinsenter/s6-overlay / /

# important: sets s6-overlay entrypoint
ENTRYPOINT ["/init"]

# runs other commands
RUN ...
```

Then run below command to build your Docker image.

```bash
docker build [build options] - < Dockerfile
```

## My other projects

Most of my [other docker projects](https://docker.shin.company) are built on top of Ubuntu 22.04 (Jammy) with s6-overlay v3 using my Ubuntu docker base images:

> 🔗 https://docker.shin.company/s6-ubuntu

[![Docker Pulls](https://img.shields.io/docker/pulls/shinsenter/s6-ubuntu)](https://docker.shin.company/s6-ubuntu) [![Docker Image Size](https://img.shields.io/docker/image-size/shinsenter/s6-ubuntu/latest?label=shinsenter%2Fs6-ubuntu)](https://docker.shin.company/s6-ubuntu)

## Supported platforms

This repository uses multi-platform images via Docker manifests. Currently, the supported architectures are:

- linux/amd64
- linux/arm/v7
- linux/arm64/v8
- linux/ppc64le
- linux/s390x

> You do not need to use a platform-specific tag (although you can), Docker will automatically choose the appropriate architecture.
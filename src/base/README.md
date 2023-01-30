# shinsenter/scratch

🗂 A multi-arch scratch image that makes it possible to cross-build images from scratch.

> 🔗 https://docker.shin.company/scratch

[![Docker Pulls](https://img.shields.io/docker/pulls/shinsenter/scratch)](https://docker.shin.company/scratch) [![Docker Image Size](https://img.shields.io/docker/image-size/shinsenter/scratch/latest?label=shinsenter%2Fscratch)](https://docker.shin.company/scratch)

* * *

## About this project

This image solves for is such a corner case that most people wouldn't run into it, so you can probably get away with `FROM scratch`.

The problem arises when you are trying to build an image for another machine architecture, and have to use `FROM scratch` in your dockerfile, in which case the resulting image will be tagged as being for the build machine's architecture instead of the target architecture (even though Qemu was used).

These Docker images are continuously updated to provide you with the most cutting-edge technology in the container world.

## Usage

Using `FROM shinsenter/scratch` creates a trusted multi-arch image tag from scratch.

```Dockerfile
FROM shinsenter/scratch

# copy files from other source
COPY ...
```

Then run below command to build your Docker image.

```bash
docker build [build options] - < Dockerfile
```

## Supported platforms

This repository uses multi-platform images via Docker manifests. Currently, the supported architectures are:

- linux/386
- linux/amd64
- linux/amd64/v2
- linux/amd64/v3
- linux/amd64/v4
- linux/arm/v6
- linux/arm/v7
- linux/arm64/v8
- linux/mips64
- linux/mips64le
- linux/ppc64le
- linux/riscv64
- linux/s390x

> You do not need to use a platform-specific tag (although you can), Docker will automatically choose the appropriate architecture.
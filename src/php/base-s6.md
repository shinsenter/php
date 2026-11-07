# shinsenter/s6-overlay

📦 s6-overlay v3 binaries as a multi-platform build stage

- Docker Hub: https://hub.docker.com/r/shinsenter/s6-overlay
- GitHub Packages: https://code.shin.company/php/pkgs/container/s6-overlay
- Main documentation (PHP images built on this stage): [shinsenter/php](https://hub.docker.com/r/shinsenter/php)


## Introduction

Unpacked [s6-overlay](https://github.com/just-containers/s6-overlay) binaries. They let one Dockerfile build for several platforms with BuildKit.

> 💡 Hint: See [s6-overlay/README.md](https://github.com/just-containers/s6-overlay/blob/master/README.md) to learn more.


## Usage

Copy the binaries into any image:

```Dockerfile
# Any base image
FROM ubuntu
ARG  S6_OVERLAY_VERSION=v3.1.6.2

# Copy the unpacked binaries
ADD --from=shinsenter/s6-overlay:$S6_OVERLAY_VERSION / /

ENTRYPOINT ["/init"]
```


## Supported Platforms

- linux/386
- linux/amd64
- linux/arm/v6
- linux/arm/v7
- linux/arm64
- linux/ppc64le
- linux/s390x


## Support the project

Keeping these images rebuilt for every PHP release takes ongoing work. If they save you time, you can help keep them going:

- ☕ [Donate via PayPal](https://www.paypal.me/shinsenter)
- 💖 [Sponsor on GitHub](https://github.com/sponsors/shinsenter)

Reporting a bug, sharing the project or giving it a star on [GitHub](https://code.shin.company/php) also helps.


## Issues and license

- Questions and bugs: [GitHub issues](https://code.shin.company/php/issues/new).
- Licensed under the [GNU General Public License v3.0](https://code.shin.company/php/blob/main/LICENSE). If you reuse ideas from this project, please give credit.

---

From Vietnam 🇻🇳 with love.

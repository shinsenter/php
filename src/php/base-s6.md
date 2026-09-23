# shinsenter/s6-overlay

🗂 Unpacked s6-overlay version 3 as a multi-platform build stage.

- Docker Hub: https://hub.docker.com/r/shinsenter/s6-overlay
- GitHub Packages: https://code.shin.company/php/pkgs/container/s6-overlay
- Main documentation: [shinsenter/php](https://code.shin.company/php)


## Introduction

Unpacked [s6-overlay](https://github.com/just-containers/s6-overlay) binaries which allow a single Dockerfile to support multiple platform build using techniques like BuildKit.

> 💡 Hint: See [s6-overlay/README.md](https://github.com/just-containers/s6-overlay/blob/master/README.md) to learn more.


## Usage

Build the following Dockerfile and try it out:

```Dockerfile
# Use your favorite image
FROM ubuntu
ARG  S6_OVERLAY_VERSION=v3.1.6.2

# Just copy unpacked binaries
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


## Contributing

If you find these images useful, consider donating via [PayPal](https://www.paypal.me/shinsenter)
or opening an issue on [GitHub](https://code.shin.company/php/issues/new).


## License

This project is licensed under the terms of the [GNU General Public License v3.0](https://code.shin.company/php/blob/main/LICENSE).

Please respect the work that went into these images. If you reuse ideas from this project, credit is appreciated.

---

From Vietnam 🇻🇳 with love.

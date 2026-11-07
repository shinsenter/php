<!--
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
-->

# About This Project

Part of the [PHP Docker Images](https://code.shin.company/php) README, moved here to keep the Docker Hub description under its 25000-byte limit.

## Supported Platforms

See the [Docker Hub tags](https://hub.docker.com/r/shinsenter/php/tags) for the platforms of each image.

> [!NOTE]
> From 2026-10-25, the rarely used platforms `linux/386`, `linux/arm/v7`, `linux/ppc64le` and `linux/s390x` are no longer built. Tags published before that date keep them until they are rebuilt.


## Stable Image Tags

For stable, production-ready images we maintain dated tags in a separate repository.

> [!NOTE]
> View stable tags: https://hub.docker.com/r/shinsenter/php-archives/tags


## How Images Are Updated

Images are no longer rebuilt on a daily schedule. The [Watch updates](https://code.shin.company/php/actions/workflows/watch-updates.yml) workflow runs every 30 minutes and compares each published image with its current inputs:

- the official `php` image of that version (new PHP release or security fix)
- Composer, docker-php-extension-installer, s6-overlay, FrankenPHP, RoadRunner
- the base OS images and the files in this repository

When an input changes, only the affected PHP versions are built again. Images that are still up to date are skipped without being pulled or built. A Composer, extension installer or s6-overlay update rebuilds the maintained versions only. Outdated versions are rebuilt when their official PHP image changes.

Each published image carries the fingerprint of its inputs in the `org.shinsenter.build.fingerprint` annotation of the image index:

```sh
docker buildx imagetools inspect --raw shinsenter/php:8.5-fpm | jq '.annotations'
```

These images are built from the official `php` image, so they can only be rebuilt after the official image for the new PHP release is published on Docker Hub. To check the PHP version in a container, run `php -v`.

Maintainers can start a build by hand from the [Build all](https://code.shin.company/php/actions/workflows/build-all.yml) workflow, with `php_versions` (for example `8.5 8.4`) and `force_build`.


## Security updates

The images are rebuilt when PHP publishes a security release. For end-of-life PHP 7.3, 7.4, 8.0 and 8.1, this project backports PHP security fixes (see [`src/php-backports`](https://code.shin.company/php/tree/main/src/php-backports)). To report a vulnerability, read [SECURITY.md](https://code.shin.company/php/blob/main/SECURITY.md). Known bugs and their fixes are in [KNOWN_ISSUES.md](https://code.shin.company/php/blob/main/KNOWN_ISSUES.md), and releases in [CHANGELOG.md](https://code.shin.company/php/blob/main/CHANGELOG.md).

<!--
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
-->

# Security Policy

## Report a vulnerability

Email [shin@shin.company](mailto:shin@shin.company). Please do not open a public issue or pull request for a vulnerability.

Include:

- the image and tag (for example `shinsenter/php:8.5-fpm-nginx`), and the OS (Debian or Alpine)
- what is affected and the impact
- steps to reproduce, or a proof of concept
- the output of `docker buildx imagetools inspect --raw <image> | jq '.annotations'`, if you can

We acknowledge the report, check it, and tell you when a fix is published. Please give us time to fix it before you disclose it, and test only what you need to show the problem.


## What is in scope

In scope: the files in this repository and the images built from them. That includes Dockerfiles, hooks and utilities in `src/php/common/rootfs/`, default settings (proxy trust, SSH, sessions, permissions), build scripts and GitHub workflows.

Out of scope, so please report it upstream:

- bugs in PHP, Nginx, Apache, FrankenPHP, RoadRunner, Composer, s6-overlay or the OS packages
- bugs in the web applications that the `src/webapps/` images install
- findings that need access you already have, such as root in the container

If you are not sure, send it to us. We will tell you where it belongs.


## Supported versions

| PHP versions | Status |
|---|---|
| 8.6-rc, 8.5, 8.4, 8.3, 8.2 | Maintained. Rebuilt when the official `php` image or another input changes. |
| 8.1, 8.0, 7.4, 7.3 | Outdated. PHP security fixes are backported (see `src/php-backports/`). |
| 7.2, 7.1, 7.0, 5.6 | Outdated. No backports. Not recommended for production. |

The list comes from `build/versions.sh`. Only the latest image of each tag gets fixes.


## Get security updates

When PHP publishes a security release, the images are rebuilt after the official `php` image for that version appears on Docker Hub. The [Watch updates](https://code.shin.company/php/actions/workflows/watch-updates.yml) workflow checks every 30 minutes and builds only the affected versions. See [How Images Are Updated](README.md#how-images-are-updated).

To apply a fix as soon as it is available:

1. Pull the image again, for example `docker pull shinsenter/php:8.5-fpm`.
2. Recreate your containers. A running container keeps the old image.
3. Check the version with `php -v`.

Before the rebuilt image is available, follow the mitigation in the PHP advisory for your version. You can set most `php.ini` options with `PHP_*` environment variables, but check that the option really mitigates the issue.

If a rebuild looks late, open a public issue with the PHP version, the image tag and a link to the PHP release notes. This is only for late rebuilds, not for new vulnerabilities.


## Safe harbor

We will not take legal action against you for reporting a vulnerability in good faith and within the limits above.


## Support the project

If these images help you, you can help keep them maintained:

- ☕ [Donate via PayPal](https://www.paypal.me/shinsenter)
- 💖 [Sponsor on GitHub](https://github.com/sponsors/shinsenter)

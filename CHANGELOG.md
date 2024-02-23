# Changelog

All notable changes to this project will be documented in this file.

## [5.0.2] - 2024-02-23

Tightened Apache directory permissions to deny access to dotfiles and system directories. This also fixes #59.

## [5.0.1] - 2024-02-16

We have made some minor improvements to the content of debug messages and variable naming.

## [5.0.0] - 2024-02-15

We are thrilled to announce the rollout of updated Docker images (v5) built directly from the [official PHP Docker images](https://hub.docker.com/_/php) to ensure you get the most up-to-date packages and bug fixes!

Check out the document and available tags on Docker Hub:
https://hub.docker.com/r/shinsenter/php
> The `-alpine` and `-tidy` tags are lightweight Alpine-based images to speed up your builds and save bandwidth.

These images are updated daily to stay current with the latest PHP, OS, and tooling updates for maximum freshness. We also apply stable version tags on a separate repo for dependable production images:
https://hub.docker.com/r/shinsenter/php-archives/tags

Old image versions (pre v5.x) now have `-deprecated` tags but will no longer receive updates. See them here:
https://hub.docker.com/r/shinsenter/php/tags?name=-deprecated

<!--
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
-->

## Contributing

If you find these images useful, consider donating via [PayPal](https://www.paypal.me/shinsenter) or open an issue on [Github](https://github.com/shinsenter/php/issues/new).

Your support helps keep these images maintained and improved for the community.

## License

This project is licensed under the terms of the [GNU General Public License v3.0](https://code.shin.company/php/blob/main/LICENSE).

I appreciate you respecting my intellectual efforts in creating them. If you intend to copy or use ideas from this project, please credit properly.

---

From Vietnam 🇻🇳 with love.

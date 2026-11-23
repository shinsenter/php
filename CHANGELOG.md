# Changelog

All notable changes to this project are documented in this file.


## [Unreleased]
- Fix `rotatelogs` missing from the Apache images (#481). The build now keeps it, with `htpasswd` and `htdigest`, when it removes the OS package.


## [6.3.0] - 2026-11-21
- Add `linux/arm/v7` (32-bit ARM) images. RoadRunner, Spiral, Hyperf and Mautic stay on `linux/amd64` and `linux/arm64`.
- Fix `fpm-apache` failing to start with "module log_config_module is built-in and can't be loaded" (#475, #479). Apache and Nginx are now always built from source and the OS package is removed after the build, so an upgrade can no longer put it back. `APACHE_VERSION=os` and `NGINX_VERSION=os` are refused. The build stops on a config syntax error.
- Fix `linux/arm/v7` images that contained the aarch64 s6-overlay binaries and failed with `Exec format error` (#478).
- Skip PHP extensions that docker-php-extension-installer does not support for the PHP version, so one unsupported module no longer fails the build. Add `mbstring`, and run `pecl upgrade-all` before the extensions (the old call used a command that does not exist).
- Skip a build when the official PHP image does not exist, so one missing image no longer fails the run and skips the other builds (#469). The official PHP 8.6 images are all ZTS, so `zts` is not built from 8.6: `8.6-zts` is a tag of the `cli` image, and `frankenphp` builds on it.
- `latest` stays on PHP 8.5. The PHP 8.6 images are published as `8.6` tags without some modules (`apcu`, `igbinary`, `msgpack`, `redis`, `sodium`, `yaml`), because docker-php-extension-installer does not support them for PHP 8.6 yet.
- The package records of Nginx and Apache (Debian and Alpine) now show the version built from source, so scanners no longer report CVEs of the older OS version.
- Use less runner time and bandwidth in the workflows: each platform builds in its own job (on a native ARM runner when possible), one Trivy scan covers all images, and jobs without work are skipped.


## [6.2.0] - 2026-11-19
- Add PHP 8.6 and make it `latest`. Drupal, PrestaShop, Nextcloud, EspoCRM, Joomla, Kirby, WordPress, Bedrock, Shopware and FrankenPHP stay at 8.5. Magento and Bagisto stay at 8.4.
- Build Apache and Nginx from source, with HTTP/2 and brotli (and HTTP/3 for Nginx on older OS).
- Raise the keep-alive of Nginx and Apache to 120 s (`NGINX_KEEPALIVE_TIMEOUT`, `APACHE_KEEPALIVE_TIMEOUT`).
- Add `TRUSTED_PROXIES=private` and a Traefik guide.
- Compress layers with zstd, sign images with cosign, report CVEs and size per publish.
- Add Craft CMS, Shopware, Tempest, Joomla, PrestaShop and Nextcloud images.
- Remove `vim-tiny` from Debian. Fix the build fingerprint, the Alpine Apache HTTP/2 modules and the WordPress download.


## [6.1.0] - 2026-11-08
- Add `TRUSTED_PROXIES` for Nginx, Apache, FrankenPHP and RoadRunner. No proxy is trusted by default (#456).
- Fix sshd in the Alpine images accepting any password over 256 bytes for an account without a password (#454). Password login stays off unless `SSHD_PASSWORD` is set.
- Add Apache variables for deflate, keep-alive, expires, overrides, the MPM profile and `reqtimeout`. Add Nginx fallbacks for old `listen`, `real_ip`, `dhparam` and IPv6.
- Change the security headers: `Referrer-Policy` is `strict-origin-when-cross-origin` (`APACHE_REFERRER_POLICY` in Apache), Apache adds `X-Content-Type-Options`, Nginx drops `X-XSS-Protection` and `Permissions-Policy`. Hide function arguments in exception traces (`PHP_ZEND_EXCEPTION_IGNORE_ARGS=1`).
- Faster responses: larger Opcache and realpath cache, and Nginx keeps connections to PHP-FPM open.
- Make Debian images 81 to 149 MB smaller and Alpine images 10 to 13 MB smaller. Debian has no `perl` unless a package needs it, and `vim-tiny` gives way to BusyBox `vi` (no `vim` command).
- Raise the Go modules of `shinsenter/dockerfile-x` to clear HIGH CVEs. `moby/buildkit` stays at 0.23.2.
- Fix the cleanup of backup and package config files and the Docker Hub README refresh. Add `tests/tools/image-slim-check.sh`.


## [6.0.0] - 2026-10-27
- Breaking: remove `APACHE_DOCUMENT_ROOT` and `NGINX_DOCUMENT_ROOT` (use `DOCUMENT_ROOT`) and `ENABLE_SSH` (use `ENABLE_SSHD`).
- Remove the sources of the unmaintained images `zz-cakephp4`, `zz-crater`, `zz-fuelphp`, `zz-hypervel`, `zz-laminas`, `zz-phpixie` and `zz-slim`. Published tags stay on Docker Hub and are not updated.
- Fix the startup ownership migration changing the owner of mounted files such as `/var/run/docker.sock` when `APP_GID` matches an existing group (#442).
- Fix variables that did not match the docs, such as `ENABLE_TUNING_FPM`, `ENABLE_SSHD`, `DEFAULT_USER` and `SMTP_FROM`. Load `custom-*.conf` from `/usr/local/etc/php-fpm.d/` after the generated settings, and let `PHP_PM*` win over `ENABLE_TUNING_FPM`.
- Add `KNOWN_ISSUES.md`.


## [5.9.0] - 2026-10-25
- Add security backports for end-of-life PHP 7.3, 7.4, 8.0 and 8.1.
- Build the latest stable brotli and curl on Alpine when the package is outdated.
- Stop building `linux/386`, `linux/arm/v7`, `linux/ppc64le` and `linux/s390x`.
- Use the exec form for `ENTRYPOINT`.
- Fix Nginx and FrankenPHP builds.
- Skip building base images when `php_versions` is set.
- Stop maintaining Docker images for Slim, Laminas, Hypervel, and CakePHP 4 due to their inactive development.


## [5.8.0] - 2026-10-22
- Replace the daily build with a watcher that builds only the images that changed.
- Skip images that are already up to date.
- Remove the Actions build cache.
- Rebuild maintained versions when Composer is updated.
- Add PHP 8.2 to the maintained versions.


## [5.7.0] - 2026-07-17
- Remove cleanup of /usr/share/zoneinfo directory.
- Remove beta job from template-php.yml.
- Temporary workaround for installing igbinary.
- Fix composer's vendor directory path.
- Fix support s6-overlay 3.2.3.2 user-bundles.


## [5.6.0] - 2025-11-20

- Use [PHP 8.5](https://www.php.net/ChangeLog-8.php#PHP_8_5) for the latest tags.
- Introducing [Hooks](https://github.com/shinsenter/php?tab=readme-ov-file#hooks).
- Added Docker images for PHP versions [8.5](https://hub.docker.com/r/shinsenter/php/tags?name=8.5).
- Added Docker images for [Bagisto](http://hub.docker.com/r/shinsenter/bagisto).
- Added Docker images for [Flight framework](http://hub.docker.com/r/shinsenter/flightphp).
- Added Docker images for [Hypervel](http://hub.docker.com/r/shinsenter/hypervel).
- Added Docker images for [Matomo](http://hub.docker.com/r/shinsenter/matomo).
- [Beta] Enable the SSH server (sshd) via the `ENABLE_SSHD` environment variable.


## [5.5.0] - 2025-07-03

- Various minor improvements.


## [5.4.0] - 2024-11-21

- Use [PHP 8.4](https://www.php.net/ChangeLog-8.php#PHP_8_4) for the latest tags.
- Various minor improvements.


## [5.3.0] - 2024-08-20

- Only updating Docker images for maintained PHP versions to save resources on scheduled builds.
- Allow downloading the source code if the value of `$INITIAL_PROJECT` is a URL to a `*.zip` or `*.tar.gz` file.
- Added Docker images for [EspoCRM](http://hub.docker.com/r/shinsenter/espocrm), [Magento Open Source](http://hub.docker.com/r/shinsenter/magento).
- Added the `$SUPERVISOR_PHP_COMMAND` variable to allow a custom command that the container will use to serve your application.
- Added hooks, shell scripts that run on events such as a container start or a new project from Composer.
- Various minor improvements.


## [5.2.0] - 2024-08-10

- The Docker images with `-tidy` tags are no longer supported. Please switch to `-alpine` images.
- The workflow builds stable images and development images (`dev-` tags).
- Stopped maintaining the Crater, FuelPHP and PHPixie images, because their projects are inactive.


## [5.1.0] - 2024-08-01

The `$PHP_*` variables now take effect only when set before the container starts. To change PHP settings from a shell inside a running container, start it with `ALLOW_RUNTIME_PHP_ENVVARS=1`.

Other updates:
- Added Docker images for PHP versions [5.6](https://hub.docker.com/r/shinsenter/php/tags?name=5.6), [7.0](https://hub.docker.com/r/shinsenter/php/tags?name=7.0), and [8.4-rc](https://hub.docker.com/r/shinsenter/php/tags?name=8.4).
- Added Docker images for [RoadRunner](http://hub.docker.com/r/shinsenter/roadrunner).
- Added Docker images for [Bedrock](http://hub.docker.com/r/shinsenter/bedrock), [CakePHP 5](http://hub.docker.com/r/shinsenter/cakephp5) and [Spiral](http://hub.docker.com/r/shinsenter/spiral).
- Improved SSL configuration for FrankenPHP containers.
- Removed warning messages from Nginx related to the HTTP2 directive.
- Fixed read/write permission issues in container directories.
- Resolved bugs in WordPress containers.
- Updated descriptions for Docker images on Docker Hub.
- Updated greeting message content upon container startup.
- Enhanced GitHub actions for building Docker images.
- Various minor improvements.


## [5.0.3] - 2024-03-12

Added Sulu containers, updated descriptions for Docker Hub repositories.


## [5.0.2] - 2024-02-23

Tightened Apache directory permissions to deny access to dotfiles and system directories. This also fixes #59.


## [5.0.1] - 2024-02-16

Improved debug messages and variable names.


## [5.0.0] - 2024-02-15

Version 5 images are built directly from the [official PHP Docker images](https://hub.docker.com/_/php). Tags and docs: https://hub.docker.com/r/shinsenter/php
> The `-alpine` and `-tidy` tags are small Alpine-based images.

The images are rebuilt daily with the latest PHP, OS and tooling. Stable version tags for production live in a separate repo: https://hub.docker.com/r/shinsenter/php-archives/tags

Images before v5.x have `-deprecated` tags and get no updates: https://hub.docker.com/r/shinsenter/php/tags?name=-deprecated

<!--
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
-->


## Contributing

If these images help you, you can donate via [PayPal](https://www.paypal.me/shinsenter) or open an issue on [GitHub](https://code.shin.company/php/issues/new).


## License

This project is licensed under the terms of the [GNU General Public License v3.0](https://code.shin.company/php/blob/main/LICENSE).

If you use or build on any of its ideas, please credit the author.

---

From Vietnam 🇻🇳 with love.

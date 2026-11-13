# Changelog

All notable changes to this project are documented in this file.


## [Unreleased]
- Compress image layers with zstd. Pulling needs Docker Engine 23.0 or later, or containerd 1.5 or later.
- Sign the published images with cosign (keyless) and attach max provenance.
- Report HIGH and CRITICAL vulnerabilities and the image size change in the job summary of each publish. Neither fails the build.
- Fix the build fingerprint. A changed Dockerfile fragment now rebuilds the image, and a change for one server no longer rebuilds the base images and the other servers.
- Add images for Shopware, Tempest, Joomla, PrestaShop and Nextcloud.
- Add a Performance section to the README and update the GitHub Actions weekly with Dependabot.
- Build Nginx with the brotli module (`google/ngx_brotli`), so `brotli` and `brotli_static` work in the `fpm-nginx` images.
- Fix the Nginx build on the Alpine images of PHP 7.4, 8.0 and 8.1, which kept the old Nginx of the OS package. Nginx uses PCRE2 on every OS.
- Build Nginx with HTTP/3 on older OS releases whose Nginx package lacks it, when their OpenSSL supports QUIC.


## [6.1.0] - 2026-11-08
- Raise the Go modules `grpc`, `containerd/v2`, `otel`, `otel/sdk` and `klauspost/compress` in the `shinsenter/dockerfile-x` image to clear HIGH CVEs. `moby/buildkit` stays at 0.23.2, because 0.28.1 does not compile with the upstream frontend.
- Add Apache variables for deflate, keep-alive, expires, overrides, the MPM profile and `reqtimeout` (`APACHE_REQUEST_READ_TIMEOUT`, no limit by default).
- Set `Referrer-Policy` to `strict-origin-when-cross-origin` in Nginx and Apache (`APACHE_REFERRER_POLICY` sets it in Apache). Add `X-Content-Type-Options` to Apache. Remove `X-XSS-Protection` and `Permissions-Policy` from Nginx.
- Hide function arguments in exception traces (`PHP_ZEND_EXCEPTION_IGNORE_ARGS=1`).
- Add Nginx fallbacks for old `listen` parameters, `real_ip`, `dhparam` and IPv6.
- Add `TRUSTED_PROXIES` (CIDRs separated by comma or space) for Nginx, Apache, FrankenPHP and RoadRunner. The server takes the client address from `X-Forwarded-For` and honors `X-Forwarded-Proto` only for the listed proxies. No proxy is trusted by default (#456).
- Delete workflow runs older than 7 days in `Watch updates`, except release builds.
- Fix the Docker Hub README refresh after a merge that changes only markdown files.
- Faster responses: larger Opcache (`PHP_OPCACHE_MEMORY_CONSUMPTION=256`, `PHP_OPCACHE_INTERNED_STRINGS_BUFFER=32`) and realpath cache (`PHP_REALPATH_CACHE_SIZE=4M`). Nginx keeps connections to PHP-FPM open (`keepalive`, `fastcgi_keep_conn`).
- Make Debian images 81 to 149 MB smaller by removing what the extension build leaves behind: `binutils`, the `gcc` sanitizer libraries, `perl`, `m4`, `patch` and `pkgconf`. The images no longer include `perl` unless another package needs it, such as `apache2`. `phpaddmod` installs the build tools again when it needs them.
- Make Alpine images 10 to 13 MB smaller by dropping the full `ncurses-terminfo` package. `ncurses-terminfo-base` stays, so `htop`, `less` and `vi` keep working in common terminals.
- Delete the `nginx.old` binary that the Nginx build leaves next to `nginx`.
- Replace `vim-tiny` with BusyBox `vi` on Debian, as Alpine already does. The `vim` command is gone.
- Fix the cleanup of backup and package config files.
- Fix sshd in the Alpine images accepting any password over 256 bytes for an account without a password (#454). Password login stays off unless `SSHD_PASSWORD` is set.
- Add `tests/tools/image-slim-check.sh`, a read-only check that lists removable packages and files in a built image.


## [6.0.0] - 2026-10-27
- Remove the sources of the unmaintained images `zz-cakephp4`, `zz-crater`, `zz-fuelphp`, `zz-hypervel`, `zz-laminas`, `zz-phpixie` and `zz-slim`. Published tags stay on Docker Hub and are not updated.
- Remove the `update-readme` workflow, which only served those images.
- Breaking: remove the legacy variables `APACHE_DOCUMENT_ROOT` and `NGINX_DOCUMENT_ROOT` (use `DOCUMENT_ROOT`), and `ENABLE_SSH` (use `ENABLE_SSHD`).
- Decide Alpine support for a PHP version in one place, `has_alpine_php` in `build/versions.sh`.
- Fix the startup ownership migration changing the owner of mounted files such as `/var/run/docker.sock` when `APP_GID` matches an existing group (#442).
- Add `KNOWN_ISSUES.md` with the user-reported bugs fixed in 5.x and 6.x.
- Fix variables that did not match the docs: `DISABLE_AUTORUN_FIX_OWNER_GROUP`, `ENABLE_TUNING_FPM`, `ENABLE_TUNING_MPM`, `ENABLE_CRONTAB_DEBUG`, `COMPOSER_OPTIMIZE_AUTOLOADER`, `SUPERVISOR_PHP_COMMAND`, `SMTP_FROM`, `ENABLE_SSHD`, `DEFAULT_USER` and `DEFAULT_GROUP`. Load `custom-*.conf` files from `/usr/local/etc/php-fpm.d/` after the generated PHP-FPM settings, and let `PHP_PM*` variables win over `ENABLE_TUNING_FPM`. Update the docs of `INITIAL_PROJECT`, `DISABLE_AUTORUN_COPYING_SOURCE`, `CRONTAB_SHELL` and `SSHD_AUTHORIZED_KEYS`.


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

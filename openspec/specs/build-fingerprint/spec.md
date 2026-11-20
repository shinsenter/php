<!--
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
-->


# Build and fingerprint

## Purpose

Behavior of `build/config.sh`, `build/helpers.sh` and the workflows. Checks: `tests/run.sh config|fingerprint|helpers|size|updates`.

## Paths
| Path | Purpose |
|---|---|
| `src/php/common/patches/distro-patch` | Moves old Debian to `archive.debian.org`; drops expired DST Root CA X3 on Debian 8, 9 and Alpine 3.7, 3.8. Run by `os-common.dockerfile` before package install and by `php-backports.dockerfile` on Debian. Mounted from the build context in a `RUN` step, so no image contains it |
| `src/php/common/patches/middleware-patch` | Alpine only. Builds latest stable brotli and curl when the package is older. Run by `os-common.dockerfile` after the package upgrade. `build/config.sh` adds both versions to the fingerprint. Mounted like `distro-patch` |
| `src/php/with-apache/apache-build` | Compiles Apache from `APACHE_VERSION` with HTTP/2 and `mod_brotli`, keeping the OS package paths, limits, module list and MPMs; stages in `/usr/src/httpd-stage`. On failure retries without HTTP/2 and brotli. `apache-install.dockerfile` copies binary and modules over the OS ones only on success. No HTTP/3 |
| `src/php/with-nginx/nginx-build` | Compiles Nginx from `NGINX_VERSION` with OS package configure flags; adds HTTP/3 when missing and brotli from latest `google/ngx_brotli` (not in the fingerprint), linked to OS brotli; builds without them on failure. `nginx-install.dockerfile` installs only on success. Mounted like `distro-patch` |
| `build/helpers.sh` | Shared functions in sections: versions, remote content, downloads, IPE modules, published images, build plan, context and hashes. One file, because every build step sources it |
| `build/check-updates.sh` | `check` prints the PHP versions to rebuild, `start` runs `build-all` unless one is running or failed in the last 3 hours, `cleanup` deletes old runs. The `watch-updates` workflow only calls it |
| `tests/` | Offline: `run.sh`. Docker: `build-test.sh`, `compose-test.sh`, `ownership-test.sh`. Helpers: `tools/`. Logs: `tests/logs/` |
| `.github/workflows/` | `build-all`, `watch-updates`, templates (`template-stack` > `template-php` > `template-common`, the four-level limit). A new server image is one entry in the `servers` list of `build-all` |
| `.github/actions/` | Shared composite actions: `registry-login`, `download-digests` (retries once), `publish` |
| `.github/dependabot.yml` | Weekly GitHub Actions updates, one grouped PR |

## Requirements


### Requirement: Build and fingerprint rules

The repo SHALL follow these rules for: build and fingerprint rules.

#### Scenario: Build and fingerprint rules
- **WHEN** this area is changed
- **THEN** all of the following hold:
- Each image SHALL have a fingerprint: a hash of everything that changes its content.
- The context hash (`get_context_hash`) SHALL cover one image: `common/`, its own `with-<server>/` folder and the `INCLUDE`d fragments in them. It SHALL leave out other servers' folders and other images' top-level Dockerfiles. Scenario: a Nginx change does not rebuild Apache or base images; a change in `src/php-backports/php<X.Y>/` rebuilds only that version.
- `NGINX_VERSION` (default `mainline`; or `stable`, a number, `os`) and `APACHE_VERSION` (default `stable`; or a number, `os`) SHALL be resolved by `build/config.sh` to a number and passed as build args. A new release changes the fingerprint of that server's images.
- `wp-cli.phar` has no version, so the WordPress fingerprint SHALL hold its published checksum.
- `build-all` SHALL download Apache and Nginx sources (with `ngx_brotli`), s6-overlay archives and `wp-cli.phar` once into the `helper_cache` artifact, with brotli and curl sources (`cache_*` in `build/helpers.sh`). `nginx-build`, `os-s6-overlay.dockerfile`, `wordpress.dockerfile` use the cached file and download only when missing, so local builds work without the artifact.
- Default images SHALL build for `linux/amd64`, `linux/arm/v7` and `linux/arm64/v8` (`set_platforms` in `build/config.sh`). `with-roadrunner` stays on amd64 and arm64: its binary has no arm/v7 build. One job per platform runs in parallel (`plan_matrix`). A job uses QEMU only when a probe shows that its runner cannot run the platform, because QEMU is much slower.
- `LATEST_PHP` SHALL name the newest PHP version whose images build. A newer version still builds, but gets no `latest` tag until it builds clean (8.6 waits for its extensions).
- A build SHALL be skipped, not failed, when Docker Hub answers 404 for the official `php:<version>-<variant>` tag (a new PHP version can lack a variant, for example `8.6-zts`). Any other answer, such as an outage or a rate limit, SHALL NOT skip a build.
- `php-extensions.dockerfile` SHALL skip the modules that `data/supported-extensions` of docker-php-extension-installer does not list for the PHP version (`get_php_skip_modules`, build arg `PHP_SKIP_MODULES`), because one failed module fails the whole install. A module PHP already has is never skipped. A lookup that fails or finds no column skips nothing. The data file is cached for 2 hours. The list is part of the cache key, limited to the modules of the image. The required-modules check at the end of the install stays: it is the only guard after `|| true`.
- Pushed layers SHALL use zstd. The temporary squash image stays gzip.
- The publish job SHALL sign each index with cosign (keyless), scan with Trivy (report only) and report the size change against the previous tag in the job summary.
- After a workflow change, `tests/tools/workflow-check.sh` MUST exit 0.

<!--
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
-->

# Layout and build notes

Paths and build behavior beyond the core table in `CLAUDE.md`.

## Paths

| Path | Purpose |
|---|---|
| `src/php/common/patches/distro-patch` | Moves old Debian releases to `archive.debian.org` and drops the expired DST Root CA X3 on Debian 8 and 9, Alpine 3.7 and 3.8. Run by `os-common.dockerfile` before the package install and by `php-backports.dockerfile` on Debian. Mounted into `RUN` steps from the build context, not part of any image |
| `src/php/common/patches/middleware-patch` | Alpine only: builds the latest stable brotli and curl when the package is older. `os-common.dockerfile` runs it after the package upgrade, which would overwrite the result. `build/config.sh` adds both versions to the fingerprint. Mounted the same way as `distro-patch` |
| `src/php/with-nginx/nginx-build` | Compiles the Nginx version from `NGINX_VERSION` with the configure flags of the OS package. It adds HTTP/3 when the OS flags lack it and the brotli module from the latest `google/ngx_brotli` commit (not part of the fingerprint), linked to the brotli library of the OS, and builds without them when that fails. `with-nginx/nginx-install.dockerfile` runs it and installs the result only when it succeeds. Mounted the same way as `distro-patch` |
| `.dockerfile-x/` | Build of the `shinsenter/dockerfile-x` image: `upstream/` submodule, `patches/go-deps` (Go modules raised for CVEs), `build.dockerfile` (single-layer image), `build.sh` |
| `tests/` | Offline tests (`run.sh` holds the tests `lint`, `versions`, `backports`, `config` and the check helpers that `ownership-test.sh` also uses). Docker tests: `build-test.sh`, `compose-test.sh`, `ownership-test.sh` (runs an existing image, does not build). `tools/`: `act-dryrun.sh`, `sbom.sh`. Logs in `tests/logs/` |
| `.github/workflows/` | `build-all`, `watch-updates` and the templates (`template-stack` > `template-php` > `template-common`, the four-level limit). A new server image is one entry in the `servers` list in `build-all`. Images rebuild only when their inputs change |
| `.github/actions/` | Composite actions shared by the templates (`registry-login`) |

## Build notes

- `build-all` downloads the Nginx source, the s6-overlay archives and `wp-cli.phar` once into the `helper_cache` artifact (`cache_nginx_source`, which also gets the `ngx_brotli` source, `cache_s6_sources`, `cache_wpcli_source` in `build/helpers.sh`, next to the brotli and curl sources). `nginx-build`, `os-s6-overlay.dockerfile` and `wordpress.dockerfile` use the cached file and download it only when it is missing, so a local build works without the artifact. `wp-cli.phar` has no version, so `build/config.sh` adds its published checksum to the fingerprint of the WordPress image.
- `NGINX_VERSION` (`mainline` by default, `stable`, a number, or `os`) is resolved to a number by `build/config.sh` and passed as a build argument. A new Nginx release changes the fingerprint of the `with-nginx` images.
- Each image has a fingerprint. `build/config.sh` adds a hash of its inputs, including `src/php-backports/php<X.Y>/`, to the cache key, so a changed patch triggers a rebuild.

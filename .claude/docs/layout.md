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

Paths and build behavior beyond the core table in `AGENTS.md`.

## Paths

| Path | Purpose |
|---|---|
| `src/php/common/patches/distro-patch` | Moves old Debian releases to `archive.debian.org`. Drops the expired DST Root CA X3 on Debian 8 and 9 and Alpine 3.7 and 3.8. `os-common.dockerfile` runs it before the package install, and `php-backports.dockerfile` runs it on Debian. A `RUN` step mounts it from the build context, so no image contains it |
| `src/php/common/patches/middleware-patch` | Alpine only. Builds the latest stable brotli and curl when the package is older. `os-common.dockerfile` runs it after the package upgrade, which would overwrite the result. `build/config.sh` adds both versions to the fingerprint. Mounted like `distro-patch` |
| `src/php/with-apache/apache-build` | Compiles the Apache from `APACHE_VERSION` with HTTP/2 and `mod_brotli`, keeping the paths, limits, module list and MPMs of the OS package (modules that need extra libraries stay as the OS built them), and stages it in `/usr/src/httpd-stage`. When the build with HTTP/2 and brotli fails, it builds again without them, like `nginx-build`. `with-apache/apache-install.dockerfile` copies the binary and modules over the OS ones only on success. Apache has no HTTP/3 |
| `src/php/with-nginx/nginx-build` | Compiles the Nginx from `NGINX_VERSION` with the configure flags of the OS package. It adds HTTP/3 when the OS flags lack it, and the brotli module from the latest `google/ngx_brotli` commit (not in the fingerprint), linked to the OS brotli library. It builds without them when that fails. `with-nginx/nginx-install.dockerfile` runs it and installs the result only on success. Mounted like `distro-patch` |
| `.dockerfile-x/` | Build of the `shinsenter/dockerfile-x` image: the `upstream/` submodule, `patches/go-deps` (Go modules raised for CVEs), `build.dockerfile` (single layer) and `build.sh` |
| `tests/` | Offline tests: `run.sh` holds `lint`, `versions`, `backports`, `config` and the others, plus the check helpers that `ownership-test.sh` reuses. Docker tests: `build-test.sh`, `compose-test.sh`, `ownership-test.sh` (runs an existing image, does not build). `tools/`: `sbom.sh`, `image-slim-check.sh`, `workflow-check.sh`. Logs go to `tests/logs/` |
| `.github/workflows/` | `build-all`, `watch-updates` and the templates (`template-stack` > `template-php` > `template-common`, the four-level limit). A new server image is one entry in the `servers` list of `build-all` |
| `.github/actions/` | Composite actions that the templates share (`registry-login`) |
| `.github/dependabot.yml` | Weekly updates for the GitHub Actions, in one grouped pull request |

## Build notes

- `build-all` downloads the Apache and Nginx sources (the latter with `ngx_brotli`), the s6-overlay archives and `wp-cli.phar` once into the `helper_cache` artifact, next to the brotli and curl sources. The functions are `cache_*` in `build/helpers.sh`. `nginx-build`, `os-s6-overlay.dockerfile` and `wordpress.dockerfile` use the cached file and download only when it is missing, so a local build works without the artifact.
- `NGINX_VERSION` is `mainline` by default, or `stable`, a number or `os`. `build/config.sh` resolves it to a number and passes it as a build argument. A new Nginx release changes the fingerprint of the `with-nginx` images.
- Each image has a fingerprint, a hash of everything that changes its content. `wp-cli.phar` has no version, so the fingerprint of the WordPress image holds its published checksum.
- `APACHE_VERSION` is `stable` by default, or a number or `os`. `build/config.sh` resolves it to a number and passes it as a build argument. A new Apache release changes the fingerprint of the `with-apache` images. `build-all` caches the source with `cache_apache_source`.
- The context part of the fingerprint (`get_context_hash` in `build/helpers.sh`) covers one image: `common/`, its own `with-<server>/` folder and the `INCLUDE`d fragments in them. It leaves out the folders of other servers and the top level Dockerfiles of other images. A change to Nginx does not rebuild Apache or the base images, and a change to `src/php-backports/php<X.Y>/` rebuilds only that version.
- Layers of the pushed images use zstd. The temporary image of the squash step stays gzip.
- The publish job signs each index with cosign (keyless), scans it with Trivy (report only) and reports the size change against the previous tag in the job summary.

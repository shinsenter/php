<!--
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
-->

# CLAUDE.md

Project context for Claude Code and human contributors. Update it when a decision or the layout changes.

## Project

Docker images for PHP (shinsenter/php), built on top of the official `php` image. PHP 5.6 to 8.6-rc, Debian and Alpine. Variants: `cli`, `zts`, `fpm`, `fpm-apache`, `fpm-nginx`, `roadrunner`, `frankenphp`, plus the webapp images in `src/webapps/`.

PHP and FPM settings change through environment variables, so changing them does not need a rebuild. Images are slimmed with `build/docker-squash`.

## Design principles

- Reuse code. One mechanism serves every PHP version. Avoid per-version branches in the logic.
- Same behavior across PHP versions. Differences live in data (for example a per-version patch folder), not in logic.
- No bloat in the base image: no extra files, no extra packages. Build packages are removed in the layer that installs them.
- Short, readable code. Comments explain why, not what. Match the style of the surrounding file.
- Verify through the build log. Do not ship check files in the image.

## Layout

| Path | Purpose |
|---|---|
| `src/php/base-php.dockerfile` | Base PHP image. `INCLUDE`s the fragments in `common/` |
| `src/php/common/` | Shared dockerfile fragments and `rootfs/` (hooks, utils) |
| `src/php/with-*.dockerfile`, `with-*/` | Web servers: apache, nginx, roadrunner, frankenphp |
| `src/php-backports/php<X.Y>/` | Security patches for end-of-life PHP versions (see below) |
| `src/webapps/` | Images for PHP frameworks and applications |
| `build/config.sh` | Produces the build variables (tag, platforms, context, fingerprint) |
| `build/versions.sh` | Version lists: maintained 8.6-rc to 8.2, outdated 8.1 to 5.6 |
| `build/helpers.sh` | Shared functions (version compare, logging, version lookups) |
| `src/php/common/patches/distro-patch` | Moves old Debian releases to `archive.debian.org` and drops the expired DST Root CA X3 on Debian 8 and 9, Alpine 3.7 and 3.8. Run by `os-common.dockerfile` before the package install and by `php-backports.dockerfile` on Debian. Mounted into `RUN` steps from the build context, not part of any image |
| `src/php/common/patches/middleware-patch` | Alpine only: builds the latest stable brotli and curl when the package is older. `os-common.dockerfile` runs it after the package upgrade, which would overwrite the result. `build/config.sh` adds both versions to the fingerprint. Mounted the same way as `distro-patch` |
| `.dockerfile-x/` | Build of the `shinsenter/dockerfile-x` image: `upstream/` submodule, `patches/go-deps` (Go modules raised for CVEs), `build.dockerfile` (single-layer image), `build.sh` |
| `tests/` | `build-test.sh`, `compose-test.sh`, `matrix-test.sh`, `sbom-test.sh`; logs in `tests/logs/` |
| `.github/workflows/` | `build-all`, `watch-updates` and the templates (`template-stack` > `template-php` > `template-common`, the four-level limit). A new server image is one entry in the `servers` list in `build-all`. Images rebuild only when their inputs change |
| `.github/actions/` | Composite actions shared by the templates (`registry-login`) |

Dockerfiles use the `INCLUDE ./path/name` syntax (dockerfile-x). `Dockerfile` and `meta.dockerfile` are generated at build time and are in `.gitignore`.

Utilities inside the image: `pkg-add` and `pkg-del` (install and remove packages per OS, read `APK_PACKAGES` and `APT_PACKAGES`), `env-default`, `hook`. Inside image layers, use these instead of calling `apk` or `apt-get` directly, so Debian and Alpine behave the same.

## Build and test

- Trial build: `tests/build-test.sh <php-version> <variant> ...` (it also builds the images it depends on). Useful variables: `SKIP_SQUASH=1`, `BUILD_TAG_PREFIX`.
- Checks that need no build: `sh -n`, `bash -n`, `git apply --check`, `git diff`.
- `NGINX_VERSION` (`mainline` by default, `stable`, a number, or `os`) is resolved to a number by `build/config.sh` and passed as a build argument. A new Nginx release changes the fingerprint of the `with-nginx` images.
- Each image has a fingerprint. `build/config.sh` adds a hash of its inputs, including `src/php-backports/php<X.Y>/`, to the cache key, so a changed patch triggers a rebuild.

## Working rules

- Do not run build or compile commands on your own (`docker build`, `docker buildx`, `tests/build-test.sh`, `./configure`, `make`, building PHP from source). Ask first and give the reason and the command. Or the user runs it and asks for follow-up changes.
- Allowed without asking: `sh -n`, `bash -n`, `git apply --check`, `grep`, `diff`.
- Do not report test results without a run or a log to back them.
- Work on a `feature/*` branch or the current branch. Never commit or push to `main`.
- Conventional Commits: `feat:` `fix:` `refactor:` `docs:` `test:` `chore:`.
- After each change, suggest a one-line commit message in English, with the type that matches semver: `feat:` is a minor bump, `fix:` is a patch bump, and a breaking change uses `!` (for example `feat!:`) for a major bump. `refactor:` `docs:` `test:` `chore:` do not bump the version. Do not commit unless the user asks.
- Edit the code directly in the working tree of the current branch. Do not write changes to `_OUTPUTS/` first. This overrides the global rule that sends all output there.
- `_OUTPUTS/` is a local scratch folder, ignored by git. Do not commit it.
- Do not touch `.env`, secrets, `.secrets` or `build/.secrets.example`.

## Security backports for EOL PHP

The official `php` images stop getting fixes at end of life. For those versions this project rebuilds PHP in place with patches from `src/php-backports/`. Versions without a folder there are not touched. Background and the current patch table are in `src/php-backports/README.md`.

### How the build works

1. `build/config.sh` (`find_backport_dir`) copies `src/php-backports/php<X.Y>/` into the build context as `php-backports/`. The folder is always there and is empty when the version has no patches.
2. `src/php/common/php-backports.dockerfile` is `INCLUDE`d by `base-php.dockerfile` as the `php-base` stage. It reads the minor version from the running PHP, then:
   - installs build dependencies (same as the official PHP Dockerfiles),
   - extracts `/usr/src/php.tar.xz` from the official image,
   - applies every `*.patch` with `patch -p1`, in file name order (`*.alpine.patch` and `*.debian.patch` only on that OS),
   - runs the `configure` command of the installed PHP (`php -i`), so flags match the variant (cli, fpm, zts),
   - runs `make` and `make install`, strips binaries, removes the source and the build packages.
3. The build stops if a patch fails to apply. The log prints each patch and each patched file. This log is the only verification, nothing is added to the image.
4. `build/config.sh` hashes the folder and the dockerfile into the image fingerprint, so a new or changed patch rebuilds the affected images and no others.

### Adding a backport

Only data changes. Do not edit `php-backports.dockerfile`, `base-php.dockerfile` or `build/config.sh` for a new patch.

1. Pick the version folder `src/php-backports/php<major.minor>/` (for example `php8.1/`). Use it only for versions the official image no longer updates. Never add a folder for a maintained version (see `MAINTAINED_PHP_VERSIONS` in `build/versions.sh`).
2. Get the upstream fix as a patch (php-src commit URL plus `.patch`). Remove the hunks that do not change code, such as `NEWS` and the test files (`*.phpt`), which may not apply to a release tarball. The patch must apply with `patch -p1` to the last release of that minor.
3. Name it `<YYYYMMDD>-<NN>-<name>.patch`: release date, then the order within that day. Security fixes use `90`, build fixes use `10`. Add `.alpine` or `.debian` before `.patch` only when the patch is OS specific.
4. Start the file with `Backport-Fix: <text>` lines (under 80 characters, one line per vulnerability unless several fit on one line). The build puts them in `php -v` and `phpinfo()`. Text before the first `diff` line is ignored by `patch`.
5. If there is no upstream patch for that version, port it by hand from the nearest version. List every difference in the file header, and tell the user the port needs review and the PHP tests before it is trusted.
6. Add a row to the table in `src/php-backports/README.md` (patch, what it fixes, source commit).
7. Check without building: `patch -p1 --dry-run` against an extracted source tree of that exact version, and `sh -n` on any shell you touched. Then ask the user to run the build (see Working rules).

### Do not

- Do not rewrite the rebuild logic per version. Differences belong in patch files and OS suffixes.
- Do not add files, tools or test code to the final image. Build packages must be removed in the same layer.
- Do not skip a failing patch or make the build continue after one fails.
- Do not rename or reorder existing patches. File name order is the apply order, and renaming changes the fingerprint of every image of that version.
- Do not put other files with a `.patch` extension in a version folder. Every `*.patch` there is applied.
- Do not keep a folder for a version the official image has fixed. Remove it and update the README table.

### Known state

- Folders exist for 7.3, 7.4, 8.0, 8.1. The 7.3 patch is a hand port of the 7.4 one.
- Not covered: 7.0 to 7.2 (no upstream patch, risky to port) and 5.6.
- Debian bullseye, buster and stretch switch to `archive.debian.org` in the build, and stay that way in the image so later layers can install packages.
- Alpine with PHP below 8.0 needs the gnu-libiconv `iconv.h` symlink. The script does it.

## dockerfile-x image

`.dockerfile-x/` builds `shinsenter/dockerfile-x`, the `# syntax` frontend that the other dockerfiles use. It builds from the `upstream/` submodule, not from `devthefuture/dockerfile-x`, so that vulnerable Go modules can be raised.

### Rules

- Keep the image minimal and single layer. `build.dockerfile` stays a plain multi-stage file. `build.sh` squashes each platform with `build/docker-squash/docker-squash.sh` (docker-squash handles one platform per run, so `build.sh` loops over platforms, pushes by digest and joins them with `imagetools create`). Do not use `buildx --squash`.
- Clean files in the final `RUN` of `build.dockerfile` while still root. The pre-squash cleanup of docker-squash runs as the image `USER` and cannot remove root-owned files.
- Runtime packages stay at `ca-certificates` and `git`. No `bash`, no ECR credential helper, no docs, man pages or apk cache. Add a package only when the frontend or the CLI needs it, and say why in the commit.
- Keep multi-platform: `linux/amd64` and `linux/arm64/v8`. No arch-specific branches beyond `TARGETARCH`.
- Do not edit files inside `upstream/`. Changes go in `patches/`. Moving the pin means `git -C .dockerfile-x/upstream checkout <tag>`, then updating `org.opencontainers.image.version` in `build.dockerfile`.
- Fix a CVE in a Go module by raising its version in `patches/go-deps`, using the fix version that Docker Scout reports. `bump-go-deps.sh` skips modules that a source tree does not use. Do not pin fix versions you have not seen in a Scout report.
- Fix an Alpine package CVE through `apk upgrade` in the final stage, not by pinning package versions.
- Name the file `build.dockerfile`. `.gitignore` excludes `**/Dockerfile`.
- Keep the author header in `build.dockerfile`, `build.sh` and `patches/*.sh`.

### Verify

- Without a build: `sh -n .dockerfile-x/patches/bump-go-deps.sh`, `bash -n .dockerfile-x/build.sh`, `git submodule status`.
- With a build (ask first, see Working rules): run `.dockerfile-x/build.sh`, then `docker scout cves shinsenter/dockerfile-x:latest --only-severity critical,high`. The goal is no CRITICAL and a lower HIGH count than before. Report the numbers from the real output only.
- Known residual risk: the CLI is packed by `pkg` with Node 18, which is end of life. Its CVEs cannot be fixed by `apk` or `patches/go-deps`.

## Copyright and credit

This project is the work of Mai Nhut Tan <shin@shin.company>, licensed under the terms in `LICENSE` (https://code.shin.company/php/blob/main/LICENSE).

- Respect the intellectual effort behind it. If you use or copy these ideas, give proper credit to the author.
- Keep the author header at the top of every file. Copy it from `src/php/base-php.dockerfile` into any new dockerfile, script or workflow, using the comment style of that file type.
- Do not remove or rewrite author, license or credit lines when editing or generating files.

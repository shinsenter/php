<!--
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
-->


# Security backports for EOL PHP

## Purpose

Official `php` images get no fixes after end of life. For such versions the build recompiles PHP with patches from `src/php-backports/php<X.Y>/`. A version without a folder is untouched. Patch table: `src/php-backports/README.md`. Check: `tests/run.sh backports`.

## Requirements


### Requirement: Build flow

The repo SHALL follow these rules for: build flow.

#### Scenario: Build flow
- **WHEN** this area is changed
- **THEN** all of the following hold:
- `build/config.sh` (`find_backport_dir`) SHALL copy the folder into the context as `php-backports/` (empty when none).
- `src/php/common/php-backports.dockerfile` (the `php-base` stage) SHALL: read the minor version from running PHP; install build deps like the official Dockerfiles; extract `/usr/src/php.tar.xz`; apply every `*.patch` with `patch -p1` in file name order (`*.alpine.patch`, `*.debian.patch` only on that OS); run the `configure` command from `php -i` so flags match the variant (cli, fpm, zts); `make`, `make install`, strip, remove source and build packages.
- The build SHALL stop when a patch fails. The build log (each patch, each patched file) is the only check. The final image SHALL carry no test files or tools.
- `build/config.sh` SHALL hash the folder and the dockerfile into the fingerprint, so a changed patch rebuilds only that version.

### Requirement: Adding a backport (data only)

The repo SHALL follow these rules for: adding a backport (data only).
- A new patch SHALL NOT edit `php-backports.dockerfile`, `base-php.dockerfile` or `build/config.sh`.
- Folder: `src/php-backports/php<major.minor>/` of a version the official image no longer updates (e.g. `php8.1/`). NEVER for a version in `MAINTAINED_PHP_VERSIONS` (`build/versions.sh`).
- Patch: upstream php-src commit URL plus `.patch`; drop non-code hunks (`NEWS`, `*.phpt`); it MUST apply with `patch -p1` to the last release of that minor.
- Name: `<YYYYMMDD>-<NN>-<name>.patch` (release date, order in day; security `90`, build fix `10`). Add `.alpine` or `.debian` before `.patch` only for OS-specific patches.
- Header: `Backport-Fix: <text>` lines, each under 80 characters, one per vulnerability unless several fit (shown in `php -v`, `phpinfo()`).
- No upstream patch for that version: port by hand from the nearest version, list every difference in the header, and tell the user it needs review and PHP tests.
- Add a row to the `src/php-backports/README.md` table: patch, fix, source commit.

#### Scenario: verify a new patch
- WHEN a patch is added THEN run `patch -p1 --dry-run` on the extracted source of that exact version and `sh -n` on touched shell, then ask the user to run the build.

### Requirement: Prohibitions

The repo SHALL follow these rules for: prohibitions.

#### Scenario: Prohibitions
- **WHEN** this area is changed
- **THEN** all of the following hold:
- MUST NOT rewrite rebuild logic per version (differences go in patch files and OS suffixes).
- MUST NOT rename, reorder or skip patches (order is apply order; a rename changes the fingerprint of every image of that version).
- MUST NOT skip a failing patch or continue after one fails.
- MUST NOT put other `.patch` files in a version folder.
- MUST NOT edit a patch to satisfy a test without asking.
- MUST remove a folder when the official image fixes that version, and update the README table.

## State (verify before relying)
- Folders: 7.3, 7.4, 8.0, 8.1. The 7.3 patch is a hand port of 7.4.
- Not covered: 7.0 to 7.2 (no upstream patch), 5.6.
- Debian bullseye, buster, stretch switch to `archive.debian.org` during the build and stay so in the image.
- Alpine with PHP below 8.0 needs the gnu-libiconv `iconv.h` symlink; the script creates it.

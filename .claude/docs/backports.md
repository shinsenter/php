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

The official `php` images stop getting fixes at end of life. For those versions this project rebuilds PHP in place with patches from `src/php-backports/`. Versions without a folder there are not touched. Background and the current patch table are in `src/php-backports/README.md`.

## How the build works

1. `build/config.sh` (`find_backport_dir`) copies `src/php-backports/php<X.Y>/` into the build context as `php-backports/`. The folder is always there and is empty when the version has no patches.
2. `src/php/common/php-backports.dockerfile` is `INCLUDE`d by `base-php.dockerfile` as the `php-base` stage. It reads the minor version from the running PHP, then:
   - installs build dependencies (same as the official PHP Dockerfiles),
   - extracts `/usr/src/php.tar.xz` from the official image,
   - applies every `*.patch` with `patch -p1`, in file name order (`*.alpine.patch` and `*.debian.patch` only on that OS),
   - runs the `configure` command of the installed PHP (`php -i`), so flags match the variant (cli, fpm, zts),
   - runs `make` and `make install`, strips binaries, removes the source and the build packages.
3. The build stops if a patch fails to apply. The log prints each patch and each patched file. This log is the only verification, nothing is added to the image.
4. `build/config.sh` hashes the folder and the dockerfile into the image fingerprint, so a new or changed patch rebuilds the affected images and no others.

## Adding a backport

Only data changes. Do not edit `php-backports.dockerfile`, `base-php.dockerfile` or `build/config.sh` for a new patch.

1. Pick the version folder `src/php-backports/php<major.minor>/` (for example `php8.1/`). Use it only for versions the official image no longer updates. Never add a folder for a maintained version (see `MAINTAINED_PHP_VERSIONS` in `build/versions.sh`).
2. Get the upstream fix as a patch (php-src commit URL plus `.patch`). Remove the hunks that do not change code, such as `NEWS` and the test files (`*.phpt`), which may not apply to a release tarball. The patch must apply with `patch -p1` to the last release of that minor.
3. Name it `<YYYYMMDD>-<NN>-<name>.patch`: release date, then the order within that day. Security fixes use `90`, build fixes use `10`. Add `.alpine` or `.debian` before `.patch` only when the patch is OS specific.
4. Start the file with `Backport-Fix: <text>` lines (under 80 characters, one line per vulnerability unless several fit on one line). The build puts them in `php -v` and `phpinfo()`. Text before the first `diff` line is ignored by `patch`.
5. If there is no upstream patch for that version, port it by hand from the nearest version. List every difference in the file header, and tell the user the port needs review and the PHP tests before it is trusted.
6. Add a row to the table in `src/php-backports/README.md` (patch, what it fixes, source commit).
7. Check without building: `patch -p1 --dry-run` against an extracted source tree of that exact version, and `sh -n` on any shell you touched. Then ask the user to run the build (see Working rules).

## Do not

- Do not rewrite the rebuild logic per version. Differences belong in patch files and OS suffixes.
- Do not add files, tools or test code to the final image. Build packages must be removed in the same layer.
- Do not skip a failing patch or make the build continue after one fails.
- Do not rename or reorder existing patches. File name order is the apply order, and renaming changes the fingerprint of every image of that version.
- Do not put other files with a `.patch` extension in a version folder. Every `*.patch` there is applied.
- Do not keep a folder for a version the official image has fixed. Remove it and update the README table.

## Known state

- Folders exist for 7.3, 7.4, 8.0, 8.1. The 7.3 patch is a hand port of the 7.4 one.
- Not covered: 7.0 to 7.2 (no upstream patch, risky to port) and 5.6.
- Debian bullseye, buster and stretch switch to `archive.debian.org` in the build, and stay that way in the image so later layers can install packages.
- Alpine with PHP below 8.0 needs the gnu-libiconv `iconv.h` symlink. The script does it.

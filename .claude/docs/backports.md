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

The official `php` images get no fixes after end of life. For those versions this project rebuilds PHP in place with patches from `src/php-backports/`. A version without a folder there is not touched.
Background and the patch table: `src/php-backports/README.md`.

## How the build works

1. `build/config.sh` (`find_backport_dir`) copies `src/php-backports/php<X.Y>/` into the build context as `php-backports/`. The folder is empty when the version has no patches.
2. `src/php/common/php-backports.dockerfile` is the `php-base` stage that `base-php.dockerfile` includes. It reads the minor version from the running PHP, then:
   - installs the build dependencies, as the official PHP Dockerfiles do,
   - extracts `/usr/src/php.tar.xz` from the official image,
   - applies every `*.patch` with `patch -p1` in file name order (`*.alpine.patch` and `*.debian.patch` only on that OS),
   - runs the `configure` command of the installed PHP (`php -i`), so the flags match the variant (cli, fpm, zts),
   - runs `make` and `make install`, strips the binaries, removes the source and the build packages.
3. The build stops when a patch fails. The log lists each patch and each patched file. The log is the only check, and the image carries no test files.
4. `build/config.sh` hashes the folder and the dockerfile into the fingerprint. A new or changed patch rebuilds the images of that version and no others.

## Add a backport

Only data changes. Do not edit `php-backports.dockerfile`, `base-php.dockerfile` or `build/config.sh` for a new patch.

1. Use the folder `src/php-backports/php<major.minor>/` of a version the official image no longer updates, for example `php8.1/`. Never add one for a maintained version (`MAINTAINED_PHP_VERSIONS` in `build/versions.sh`).
2. Take the upstream fix as a patch (the php-src commit URL plus `.patch`). Remove hunks that do not change code, such as `NEWS` and `*.phpt` test files, which may not apply to a release tarball. The patch must apply with `patch -p1` to the last release of that minor.
3. Name it `<YYYYMMDD>-<NN>-<name>.patch`: the release date, then the order within that day. Security fixes use `90`, build fixes use `10`. Add `.alpine` or `.debian` before `.patch` only for an OS-specific patch.
4. Start the file with `Backport-Fix: <text>` lines, each under 80 characters, one per vulnerability unless several fit on a line. The build puts them in `php -v` and `phpinfo()`. `patch` ignores text before the first `diff` line.
5. With no upstream patch for that version, port it by hand from the nearest version. List every difference in the file header. Tell the user the port needs review and the PHP tests before anyone trusts it.
6. Add a row to the table in `src/php-backports/README.md`: patch, what it fixes, source commit.
7. Check without a build: `patch -p1 --dry-run` on an extracted source tree of that exact version, and `sh -n` on any shell you touched. Then ask the user to run the build.

## Do not

- Do not rewrite the rebuild logic per version. Differences belong in patch files and OS suffixes.
- Do not add files, tools or test code to the final image. Remove build packages in the layer that installs them.
- Do not skip a failing patch or let the build continue after one fails.
- Do not rename or reorder patches. File name order is the apply order, and a rename changes the fingerprint of every image of that version.
- Do not put other `.patch` files in a version folder. The build applies every one of them.
- Do not keep a folder for a version the official image has fixed. Remove it and update the README table.

## Known state

- Folders exist for 7.3, 7.4, 8.0 and 8.1. The 7.3 patch is a hand port of the 7.4 patch.
- Not covered: 7.0 to 7.2 (no upstream patch, risky to port) and 5.6.
- Debian bullseye, buster and stretch switch to `archive.debian.org` during the build and stay that way in the image, so later layers can install packages.
- Alpine with PHP below 8.0 needs the gnu-libiconv `iconv.h` symlink. The script creates it.

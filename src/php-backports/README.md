# PHP security backports

Security fixes for PHP versions that the official `php` images no longer update.
`src/php/common/php-backports.dockerfile` rebuilds PHP in place with these patches
before the rest of `base-php.dockerfile` runs. Other versions are not touched.

- One folder per version: `php<major.minor>/` (for example `php8.1/`).
- Every `*.patch` in the folder is applied in file name order. Name them
  `<YYYYMMDD>-<NN>-<name>.patch`: release date, then the order within that day.
- `*.alpine.patch` and `*.debian.patch` are applied on that OS only.
- To add a backport, add a patch file to the folder. Nothing else changes.
- A patch can start with lines `Backport-Fix: <text>` (for people to read, under 80 characters: put the vulnerabilities fixed by the same patch on one line when it fits, otherwise one line each). The build adds them, in patch order, at the end of the Zend Engine info of `php -v` and `phpinfo()`, after the extension lines (`    with Zend OPcache ...`). Text before the first `diff` line is ignored by `patch`.
- To drop a version, delete its folder.
- Verify from the build log: it prints each patch and each patched file. The build stops if a patch does not apply.

| Patch | Fixes | Source |
|---|---|---|
| `20261018-90-CVE-2026-109618-109619.patch` in `php7.4` | GHSA-w8hw-w9fx-j79w, GHSA-6wmf-4rv5-p3rp | php-src `712e60f9edfd03f0960fc4fc3c2c375f42b90aa2` |
| same in `php8.0` | same | php-src `82f8f31b16a035c1b67cc253e79f7cc288f4cc20` |
| same in `php8.1` | same | php-src `1d7dec178a094e6e75b229ce22754045f8c6070a` |
| same in `php7.3` | same | ported by hand from the 7.4 patch (see the header of the file) |
| `20240408-10-gh-11678-musl.alpine.patch`, `20240706-10-gh-14834-pear.alpine.patch` in `php8.1` | build fixes the official Alpine image applied | php-src `577b8ae`, `67259e4` (`NEWS` hunk removed; the `compat.c` hunk of `67259e4` is adapted to 8.1.34, see the file header) |

The CVE patches are the php-src commits without the hunks that only update tests (`ext/zend_test/tests`, 3 files in the 8.1 patch). They do not change code.

`php7.3` has no upstream patch. Its CVE patch is the 7.4 patch ported by hand to 7.3.33: same changes, adapted where the 7.3 source differs (the header of the file lists the differences). Review it and run the PHP tests before relying on it.

## About CVE-2026-109618 and CVE-2026-109619

Two critical remote code execution bugs, published 2026-10-21. Upstream fixed them in 8.2.35, 8.3.36, 8.4.27 and 8.5.12. For 8.1 and older, php-src only has a "minimal mitigation for EOL version" (the patches here). The advisories say updating to a fixed release is the only complete mitigation.

- [CVE-2026-109618](https://github.com/php/php-src/security/advisories/GHSA-w8hw-w9fx-j79w) (GHSA-w8hw-w9fx-j79w), RCE via OOM corruption. PHP leaves the request state invalid when an out-of-memory error exits early with `longjmp()`, and request shutdown then reads it. Multipart requests can reach OOM within the normal limits (many headers in one part, empty file fields, no content length).
- [CVE-2026-109619](https://github.com/php/php-src/security/advisories/GHSA-6wmf-4rv5-p3rp) (GHSA-6wmf-4rv5-p3rp), RCE via stale global state. A worker keeps global pointers (error, session, object, extension state) to memory of a finished request. The next request can use them before initialization (use after free).

What the patches change, as seen in the code:

- Memory and size overflow errors print `Fatal error: ...` and end the process with `_exit(1)`, instead of unwinding through `zend_bailout()`. A worker that hits OOM is replaced, not reused.
- Request shutdown resets the global pointers that were left stale.
- Multipart parsing: new ini `max_multipart_body_parts` (default `-1`, which means `max_input_vars` + `max_file_uploads`; a warning is raised over the limit), only `Content-Disposition` and `Content-Type` headers are kept, and duplicate headers are ignored.
- `session.upload_progress` no longer works (the session upload callback returns early).
- Nested input names (`a[][]=1`) create arrays with the smallest table size.

## Alpine libraries: CVE-2026-111497 and CVE-2026-92392

These two are not php-src bugs, so they are not patches in this folder. `src/php/common/patches/middleware-patch` fixes them for every PHP version on Alpine. `os-common.dockerfile` runs it right after the package upgrade, because the upgrade would overwrite the result.

| CVE | Library | Affected | Fixed | Alpine package at the time |
|---|---|---|---|---|
| CVE-2026-111497 | brotli (out-of-bounds write in the decoder) | 1.0.3 to 1.2.0 | 1.2.1 | `brotli-libs` 1.2.0-r1 |
| CVE-2026-92392 | curl (HTTP/2 upload use-after-free) | 8.12.0 to 8.22.0 | 8.23.0 | 3.23 has 8.22.0-r0; 3.21 and 3.22 have a backport in 8.14.1-r3 and -r4 |

- The script looks up the latest stable release of brotli and curl on GitHub and builds a library only when the installed Alpine package is older. When Alpine ships a package that is as new, `pkg-add upgrade` installs it and the script does nothing.
- `build/config.sh` adds both versions to the image fingerprint, so a new release rebuilds the Alpine images. The sources are downloaded over HTTPS without a checksum. curl uses the configure options of the Alpine package.
- Only the shared libraries (`libbrotli*.so.*`, `libcurl.so.*`) and `/usr/bin/curl` are replaced. Build packages are removed in the same layer.
- `apk info` still reports the old version, so an SBOM scan can still list the old one. Check the files instead: the build log prints `curl -V` and the `libbrotli` files.
- curl 8.23.0 also fixes 23 other CVEs of 8.22.0 and older.

## Old operating systems

- Debian `stretch`, `buster` and `bullseye` are moved to `archive.debian.org` in the build (and stay that way in the image, so later layers can install packages).
- Alpine 3.16 is still served by `dl-cdn.alpinelinux.org`. PHP below 8.0 needs the GNU libiconv headers linked into `/usr/include`, the script does it.

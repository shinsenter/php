# Known issues

Bugs that users reported on [GitHub issues](https://github.com/shinsenter/php/issues) and that were fixed in the 5.x and 6.x releases. Each entry names the first release that contains the fix.

Not listed: usage questions, behavior that works as designed, problems caused by the host or by upstream projects, and reports the maintainer could not reproduce.

`Open` lists limits that are known and not fixed yet.

Where an entry says "cause not recorded", the issue thread does not say what was wrong. The fix shipped in rebuilt images and the issue thread links no change.

## Open

### Setuid root helpers give a compromised app user a path to root

Code that runs as the application user (`www-data` by default) can call helpers installed with the setuid bit and run commands as root.

- Cause: by design. `web-do`, `autorun`, `ownership` and the `web-*` tools need root to switch users and fix owners, so `os-common.dockerfile` installs them with mode 4755. Not checked whether this `su-exec` build refuses to switch to root.
- Fix: not fixed. Needs a design change, such as limiting the helpers to root or a dedicated group.

### The PHP 8.6 images lack some modules

`apcu`, `igbinary`, `msgpack`, `redis`, `sodium` and `yaml` are missing from the `8.6` tags, so code that needs them fails. `latest` stays on PHP 8.5 until they are back.

- Cause: docker-php-extension-installer (IPE) does not support them for PHP 8.6 yet, so the build skips them (`PHP_SKIP_MODULES`).
- Fix: not fixed. The build reads the IPE list each time, so a module returns when IPE adds it. Then move `LATEST_PHP` in `build/config.sh` to 8.6.

### `hyperf` and `mautic` have no `linux/arm/v7` image

Both build for `linux/amd64` and `linux/arm64` only (`platform=` in `APP_RULES` of `build/config.sh`).

- Cause, `hyperf`: IPE installs `swoole-5.0.3` on arm/v7, and it does not compile with PHP 8.2 to 8.5. Why IPE picks it is not recorded.
- Cause, `mautic`: on Debian, `imap` needs `libc-client2007e`, which depends on `libssl3`, and apt cannot install it on armhf. Alpine built, but the rule skips both.
- Fix: not fixed. Remove the `platform=` rule when `swoole` and `imap` install on arm/v7.

### [#481](https://github.com/shinsenter/php/issues/481) `fpm-apache` stops: "Couldn't start ErrorLog process '/usr/bin/rotatelogs'"

The Apache images of 6.3.0 have no `/usr/bin/rotatelogs`, so an `ErrorLog` that pipes to it fails at start.

- Cause: the build removes the OS package with `apache2-utils` and copies back only `apache2` and the modules.
- Fix: `apache-install.dockerfile` also copies `rotatelogs`, `htpasswd` and `htdigest` with their libraries.
- Tested: `with-apache` 8.2 on arm64, Debian and Alpine. The tools run, and Apache answers 200 with the piped `ErrorLog`. amd64 and arm/v7 not run.

## 6.3.0

### [#478](https://github.com/shinsenter/php/issues/478) arm/v7 images contain an aarch64 `s6-overlay-suexec`

The arm/v7 images stop at start with `Exec format error`: `s6-overlay-suexec` is an aarch64 binary.

- Cause: `os-s6-overlay.dockerfile` chose the archive from `uname -m`, and an arm64 builder reports `aarch64` for an arm/v7 build.
- Fix: the archive follows `TARGETARCH` and `TARGETVARIANT`, with `uname -m` as the fallback.
- Tested: `tests/run.sh config` fails on the old file. Local arm/v7 builds have a 32-bit ARM binary. Not run in a container.

### [#479](https://github.com/shinsenter/php/issues/479) `fpm-apache` of PHP 8.5 stops with "module log_config_module is built-in"

Same error as #475, on the published `php8.5` image: the Debian Apache binary has `log_config` and other modules built in, while `modules.conf` still loads them.

- Cause: the cleanup before the squash runs `apt-get full-upgrade`. Apt saw the source build `2.4.71` as older than the OS `2.4.71-1~deb13u1` and put the OS Apache back.
- Fix: Apache and Nginx are always built from source and the OS package is removed after the build, so an upgrade has nothing to replace. `APACHE_VERSION=os` and `NGINX_VERSION=os` are refused.
- Tested: 48 local builds with the squash step (PHP 5.6 to 8.6, Debian and Alpine, Apache and Nginx): source binary, `apache2 -t` OK, HTTP 200. The CI image is not tested.

### [#469](https://github.com/shinsenter/php/issues/469) A missing upstream PHP image fails the build and skips the servers and apps of every PHP version

When `php:8.6-cli-alpine` did not exist yet, those builds failed and the jobs on top of them were skipped for every version. The `8.5-*` tags stayed on 8.5.12 although 8.5.13 fixed two critical vulnerabilities.

- Cause: `base` is one workflow call for all versions, so one failed version fails `base` and skips the servers and apps of the others. Read from the workflows, not from the failed run.
- Fix: `build/config.sh` skips a build, instead of failing it, when Docker Hub answers 404 for the official `php` tag. Other answers (outage, rate limit) do not skip. `zts` is not built from 8.6: `8.6-zts` is a tag of `cli`.
- Tested: `tests/run.sh helpers` covers a 404, a rate limit and no answer. `config.sh` gives `SKIP_BUILD=0` for `fpm` and `cli` 8.6 and `1` for `zts` 8.6. A full pipeline run is not tested.

### [#475](https://github.com/shinsenter/php/issues/475) Apache stops: "module log_config_module is built-in and can't be loaded"

The `fpm-apache` images of 6.2.0 and 6.2.1 fail to start with a syntax error in `modules.conf` for `log_config_module` and `unixd_module`.

- Cause: the published image has both modules built in, but `apache-config.dockerfile` also wrote them to `modules.conf`, so Apache loaded them twice. Why that binary has them built in is not recorded.
- Fix: the config step reads the built-in modules from `apache2 -l` and leaves them out. The build stops on an `apache2 -t` error.
- Tested: on the published `8.3-fpm-apache`, removing the two lines gives `Syntax OK`. Local builds pass `apache2 -t` but have both modules as shared, so they do not show the original error.

## 6.1.0

### [#456](https://github.com/shinsenter/php/issues/456) Client IP behind Cloudflare wrong in the first 6.1.0 build

Images from the first `6.1.0` build trusted `X-Forwarded-For` from private ranges, so an app behind Cloudflare saw a Cloudflare address as the client IP. The tag was moved, so new images are fine. Images pulled earlier keep the problem.

- Cause: Nginx and Apache trusted the private ranges by default. The load balancer in front is in one, so the server took the next address in the header, a Cloudflare one.
- Fix: no proxy is trusted by default. `TRUSTED_PROXIES` turns it on, and Cloudflare ranges can go in it. The same build also turned `SMTP_TLS` on with `SMTP_USER` or `SMTP_PASSWORD`, set `PHP_SESSION_USE_STRICT_MODE` to `1`, and added Apache `reqtimeout` and Nginx `open_file_cache` defaults. All are back to opt-in or removed.
- Tested: `tests/run.sh scaling` and `defaults`, and HTTP checks on PHP 8.4 Debian images. Not tested with a real proxy.

### [#454](https://github.com/shinsenter/php/issues/454) Alpine: sshd accepts passwords over 256 bytes for `*` accounts

Not reported by a user. On Alpine, a password of 257 bytes or more logs in to any account locked with `*`. Debian is not affected.

- Cause: with `ENABLE_SSHD=1` and `SSHD_PASSWORD_AUTH=1` but no `SSHD_PASSWORD`, the hook set the field to `*` and still wrote `PasswordAuthentication yes`. musl's `crypt()` returns `*` for such a password, which matches.
- Fix: the hook writes `PasswordAuthentication no` for an account with no password and prints a warning.
- Still open: with `SSHD_PERMIT_ROOT_LOGIN=1` and password auth on for another user, the bypass works for `root` on Alpine 3.16 and later. Keep `SSHD_PERMIT_ROOT_LOGIN` off.
- Tested: `tests/run.sh ssh` with stub commands. Not tested with a real sshd.

### [#451](https://github.com/shinsenter/php/issues/451) `apache2: not found` in the Debian Apache images

Debian Apache images started PHP-FPM but not Apache (`apache2: command not found`), including images built on `phpfpm-apache`.

- Cause: the cleanup hook `10-toolchain-leftovers` removed `perl`, and `apt-get purge` took `apache2` with it. FrankenPHP Debian images lost `mailcap` and `media-types` the same way, with no startup error.
- Fix: the hook removes a package group only when `apt-get -s` shows nothing else goes with it. Apache and FrankenPHP images keep `perl`.
- Tested: HTTP checks pass for Nginx, Apache, FrankenPHP and RoadRunner on Debian and Alpine with PHP 8.5 to 8.2. Older versions were still being tested at merge.

## 6.0.0

### [#442](https://github.com/shinsenter/php/issues/442) Startup changed the owner of the host Docker socket

`APP_GID` set to an existing GID made startup change the owner of mounted files, such as `/var/run/docker.sock` (`root:docker` to `1001:33`).

- Cause: `groupmod` failed but `ownership` still ran `find / -xdev`, and `-xdev` does not skip a mount point that is a file. `DISABLE_AUTORUN_FIX_OWNER_GROUP` does not cover this step.
- Fix: `ownership` keeps the current GID when `groupmod` fails, and `find` skips mount points, sockets and devices. `web-chown` uses `chown -h`.
- Tested: the `find` expression on a sample tree. Not tested in a container.

## 5.9.0 and 5.8.0

### [#436](https://github.com/shinsenter/php/issues/436) `8.5-fpm` image shipped without most extensions

The Debian `8.5-fpm` image pushed on 2026-10-21 had only `apcu` and `sodium`. `mysqli` and `pdo_mysql` were missing, which broke WordPress sites after a pull.

- Cause: not recorded.
- Fix: the image was rebuilt on 2026-10-22 (5.8.0).

## 5.7.0

### [#423](https://github.com/shinsenter/php/issues/423), [#424](https://github.com/shinsenter/php/issues/424), [#428](https://github.com/shinsenter/php/issues/428) Containers crash at boot after the 2026-07-15 rebuild

`s6-rc-compile` stopped with `unable to read /etc/s6-overlay/s6-rc.d/user/type`, so no service started. Alpine and Debian images, Apache and Nginx variants, were affected.

- Cause: a regression in s6-overlay v3.2.3.1 ([just-containers/s6-overlay#643](https://github.com/just-containers/s6-overlay/issues/643)).
- Fix: pinned v3.2.3.0 first, then moved to v3.2.3.2 and removed the pin.

### [#394](https://github.com/shinsenter/php/issues/394) `TZ` had no effect on the system time

`/etc/localtime` pointed to `/usr/share/zoneinfo/Etc/UTC`, and the file was gone because image cleanup deleted `/usr/share/zoneinfo`.

- Fix: image cleanup keeps `/usr/share/zoneinfo`.

### [#390](https://github.com/shinsenter/php/issues/390) PHP 8.5 image missing `redis`, `gd`, `intl` and `zip`

- Cause: extension installation failed during the 8.5 build, partly because of `igbinary`.
- Fix: the build updates PEAR and installs `igbinary` last, with a temporary `igbinary` workaround.

## 5.6.0

### [#380](https://github.com/shinsenter/php/issues/380) `web-mkdir` changed permissions of existing directories

The existence check used `-f` (file) instead of `-d` (directory), so `install -d` ran on every start and reset permissions on bind-mounted project folders.

- Fix: the check uses `-d`. The reporter contributed the change.

### [#378](https://github.com/shinsenter/php/issues/378) `PHP_MAX_EXECUTION_TIME` did not change the Apache timeout

The hook wrote `timeout.conf` to `/etc/apache2/conf-enabled`, which the image does not load. Apache kept the default 60 seconds. `apache-mpm` used the same wrong path.

- Fix: both files are written to `/etc/apache2/mods-enabled`.

### [#364](https://github.com/shinsenter/php/issues/364) Container stopped with `unexpected EOF` after `Hook: rebooted`

The log showed `Changed www-data UID: X → X`. The `ownership` script compared the new UID against the new GID, so it reported a UID change that did not exist.

- Fix: the script compares UID with UID. Only the ownership part of this report is traced to a fix. The `unexpected EOF` itself is not traced.

### [#363](https://github.com/shinsenter/php/issues/363) Apache variant looped on `exec: : not found`

The Apache service script asked s6 for the `nginx` dependency instead of `apache`, so `wait-for` received an empty target. In Apache images that leaves nothing for `exec` to run.

- Fix: the script asks for the `apache` dependency.

### [#353](https://github.com/shinsenter/php/issues/353) Laravel Reverb did not start

The run script passed `reverb:start` twice, and Artisan rejected the second one: `No arguments expected for "reverb:start" command`.

- Fix: the script removes the duplicate argument.

### [#332](https://github.com/shinsenter/php/issues/332) `exec format error` on ARM

`su-exec` had no working ARM binary, so `SUPERVISOR_PHP_COMMAND` failed on ARM nodes.

- Fix: the maintainer forked the abandoned project as [shinsenter/su-exec](https://github.com/shinsenter/su-exec) and builds ARM binaries.

### [#324](https://github.com/shinsenter/php/issues/324) `SUPERVISOR_PHP_COMMAND` appended an extra `php` argument

`php artisan reverb:start` ran as `php artisan reverb:start php`.

- Cause: not recorded.

### [#279](https://github.com/shinsenter/php/issues/279) `readpath: command not found`

`app-path` called `readpath`, a typo of `realpath`. Debian images were affected.

- Cause: typo in `app-path`. No change is linked.

### [#270](https://github.com/shinsenter/php/issues/270) Environment variables missing in cron jobs

Cron jobs lost the container environment on Debian images. Alpine images were not affected.

- Cause: not recorded. The maintainer points to pull request #271, which is not in the current history.

## 5.5.0

### [#230](https://github.com/shinsenter/php/issues/230) `s6-rc-compile` failed on the Nginx and Apache variants

The error was `unable to read /etc/s6-overlay/s6-rc.d/nginx/type`.

- Fix: `s6-service` no longer exits early when the service directory already exists. This change is the likely fix and the thread does not confirm it.

### [#209](https://github.com/shinsenter/php/issues/209) `$_SERVER['SCRIPT_FILENAME']` started with `//`

The Apache variant sent PHP requests to FPM with a trailing slash in the handler URL and used the generic FastCGI backend type.

- Fix: the config sets `ProxyFCGIBackendType FPM` and removes the trailing slash.

### [#190](https://github.com/shinsenter/php/issues/190) Pre-installed extensions missing from `8.2-fpm-apache`

`php -m` listed only the default extensions. The extension step ended with `|| true`, so a failed install did not stop the build.

- Fix: the images were rebuilt. the build now fails when an extension does not install.

### [#157](https://github.com/shinsenter/php/issues/157) `zz-generated-settings.ini` had a syntax error

`php-envvars` put a backslash before `=` in quoted values, so `tcp://redis:6379?auth=test` became `auth\=test`. PHP then failed to parse the file.

- Fix: `=` is no longer escaped.

## 5.4.0

### [#159](https://github.com/shinsenter/php/issues/159) Magento image stopped on `duplicate location "/"`

Nginx rejected the default site because the Magento config defines its own `location /`.

- Fix: the Magento image renames the default `location /` when the Magento config has one.

### [#145](https://github.com/shinsenter/php/issues/145) Apache rewrite rules worked only partly

`apache2.conf` enabled `MultiViews`, which maps `/search` to `search.php` before rewrite rules run. Another user ([#176](https://github.com/shinsenter/php/issues/176)) fixed a 404 on `/update` the same way.

- Fix: the config sets `-MultiViews`.

### [#140](https://github.com/shinsenter/php/issues/140) `FIX_APP_PATH_PERMISSION=0` did not keep permissions of a mounted folder

Copying `.env.example` to `.env` triggered an ownership fix of the whole application path.

- Fix: the copy no longer triggers the ownership fix. The reporter confirmed the folder keeps its permissions when `APP_UID` matches the folder owner. With a different owner, the permissions still change to `755`.

### [#132](https://github.com/shinsenter/php/issues/132) `crond: can't lock /var/run/crond.pid`

The hook killed a stale `crond` from `crond.pid` and printed the failure, which stopped `50-crontabs` with an error.

- Fix: the hook silences the output of `kill`. The reporter confirmed cron jobs ran after updating the image.

## 5.3.0

### [#85](https://github.com/shinsenter/php/issues/85) `composer install` no longer ran automatically

- Cause: not recorded. The reporter had to run it in an init script until the images were rebuilt.

## 5.1.0

### [#77](https://github.com/shinsenter/php/issues/77) Apache failed with `No MPM loaded` after an update

Containers stopped with `s6-rc failed` after Debian updated Apache to 2.4.61.

- Cause: not recorded. The reporter confirmed the rebuilt images worked on 2024-07-23.

### [#68](https://github.com/shinsenter/php/issues/68) Statamic 5 image URLs under `/img/` returned an Nginx 404

Nginx served image-like requests as static files and did not pass them to PHP when the file did not exist. Statamic Glide generates such URLs on demand.

- Fix: the maintainer routes image requests that match no file to PHP. The reporter confirmed Glide worked.

### [#62](https://github.com/shinsenter/php/issues/62) `pecl` failed inside the container

`pecl install mongodb` stopped with `Failed to set memory limit to 0 bytes` and `The default config file is not a valid config file or is corrupted`.

- Cause: not recorded.
- Fix: images rebuilt on 2024-04-29. The release tag that first follows is 5.1.0. Use `phpaddmod` at build time to add extensions.

## 5.0.2

### [#59](https://github.com/shinsenter/php/issues/59) Apache returned 403 for `.html` files

`.php` files worked while static `.html` files returned `AH01630: client denied by server configuration` on `8.2-fpm-apache`.

- Cause: a mistake in the Apache settings, confirmed by the maintainer. Details not recorded.
- Fix: released in 5.0.2.

### [#57](https://github.com/shinsenter/php/issues/57) Autorun scripts did not run in `WORKDIR`

Scripts in `/startup` no longer started in the application directory, so relative paths broke.

- Cause: not recorded. The fix shipped in the 5.0.2 images.

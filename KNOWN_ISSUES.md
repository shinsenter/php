# Known issues

Bugs that users reported on [GitHub issues](https://github.com/shinsenter/php/issues) and that were fixed in the 5.x and 6.x releases. Each entry names the first release that contains the fix.

Not listed: usage questions, behavior that works as designed, problems caused by the host or by upstream projects, and reports the maintainer could not reproduce.

Where an entry says "cause not recorded", the issue thread does not say what was wrong. The fix shipped in rebuilt images and the issue thread links no change.

## 6.0.0

### [#442](https://github.com/shinsenter/php/issues/442) Startup changed the owner of the host Docker socket

With `APP_GID` set to a GID that already exists in the image (998 is `systemd-network` in Debian), `groupmod` failed but `ownership` still ran `find / -xdev` and moved every file with the old UID or GID to the new owner. `-xdev` does not skip a mount point that is a file, so a mounted `/var/run/docker.sock` changed from `root:docker` to `1001:33`. `DISABLE_AUTORUN_FIX_OWNER_GROUP` does not cover this step, as the entrypoint always runs `ownership`.

- Fix: `ownership` keeps the current GID when `groupmod` fails. The `find` skips mount points, `/proc`, `/sys`, `/dev`, sockets and devices. `web-chown` uses `chown -h`, so a symlink in the application path no longer changes the file it points to.
- Not tested in a container yet. The `find` expression was checked on a sample tree.

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

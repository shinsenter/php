<!--
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
-->
# System settings

Environment variables that tune the container.

## SSH access

Set `ENABLE_SSHD=1` and publish port 22. See [SSH access](https://code.shin.company/php#ssh-access) for an example.

| Variable | Default | Effect |
|---|---|---|
| `SSHD_AUTHORIZED_KEYS` | not set | Public keys, one per line. When not empty, they replace `~/.ssh/authorized_keys` at every start |
| `SSHD_USER` | `$APP_USER` | User to log in as |
| `SSHD_PORT` | `22` | Port that sshd listens on |
| `SSHD_PASSWORD_AUTH`, `SSHD_PASSWORD` | `0`, not set | Password login stays off unless both are set |
| `SSHD_PERMIT_ROOT_LOGIN` | `0` | Allow root login |
| `SSHD_SFTP_ONLY` | `0` | Allow SFTP only, no shell |

## General

| Setting Name | Default Value | Description |
|---|---|---|
| `DEFAULT_LOG_PATH`                 | `/proc/1/fd/2`   | Where logs are written. By default, logs are sent to the container's stdout. |
| `DEBUG` or `DEBUG_MODE`            | Not set          | Enable verbose logging when set to `1`. |
| `TZ`                               | `UTC`            | Set the container's timezone. See the list of timezones. |
| `ALLOW_RUNTIME_PHP_ENVVARS`        | Not set          | Allow `$PHP_*` variables to override PHP configuration at runtime. |
| `DISABLE_GREETING`                 | Not set          | Suppress the startup greeting with `1`. |
| `SUPERVISOR_PHP_COMMAND`           | Not set          | Override the PHP command used by supervisor. Quotes group arguments that contain spaces. |

## Project startup and autorun

| Setting Name | Default Value | Description |
|---|---|---|
| `INITIAL_PROJECT`                  | Not set          | Used only when the app directory is empty. A URL starting with `http` and ending in `.zip` or `.tar.gz` is downloaded and extracted. A URL ending in `.git` is cloned. A value like `vendor/package` is created with `composer create-project`. Any other value runs the `create-project` hook. |
| `INITIAL_PROJECT_GIT_OPTIONS`      | Not set          | Options passed to `git clone` when `INITIAL_PROJECT` is a `http*.git` URL. |
| `DISABLE_AUTORUN_SCRIPTS`          | Not set          | Set to `1` to disable autorun scripts. |
| `DISABLE_AUTORUN_CREATING_PROJECT` | Not set          | Do not create a project from `INITIAL_PROJECT` when `1`. It does not stop copying `/source/`. |
| `DISABLE_AUTORUN_COPYING_SOURCE`   | Not set          | Do not copy the files of `/source/` into the app directory when `1`. The copy runs only when the app directory is empty. |
| `DISABLE_AUTORUN_COMPOSER_INSTALL` | Not set          | Skip running `composer install` during startup when set to `1`. It does not stop `COMPOSER_OPTIMIZE_AUTOLOADER`. |
| `DISABLE_AUTORUN_GENERATING_INDEX` | Not set          | Do not generate `index.php` when set to `1`. |
| `DISABLE_AUTORUN_FIX_OWNER_GROUP`  | Not set          | When `1`, no command changes the owner of files in `APP_PATH` or `DOCUMENT_ROOT`: no ownership fix, no owner on created directories, and no UID/GID migration there. Files and directories the container creates there, such as a missing `DOCUMENT_ROOT` or `index.php`, belong to root, so set the owner of paths that `APP_USER` must write to yourself. |
| `COMPOSER_OPTIMIZE_AUTOLOADER`     | Not set          | When `1`, run `composer dumpautoload --optimize --no-cache` at startup if `composer.lock` and the `vendor` directory exist. |

## Cron

| Setting Name | Default Value | Description |
|---|---|---|
| `ENABLE_CRONTAB`                   | Not set          | Enable Crontab service when `1`. Jobs are loaded from `$CRONTAB_DIR`. |
| `ENABLE_CRONTAB_DEBUG`             | Not set          | Adds a debug cron job that runs every minute when `1`. When set, it takes priority over `DEBUG`, so `0` removes the job even if `DEBUG=1`. |
| `CRONTAB_DIR`                      | `/etc/crontab.d` | Directory for crontab definitions. Jobs run as `$APP_USER`. |
| `CRONTAB_HOME`                     | `$APP_PATH`      | Home directory for cron jobs. |
| `CRONTAB_MAILTO`                   | Not set          | Email address to receive cron output. |
| `CRONTAB_PATH`                     | `$PATH`          | Executable search path used by cron jobs. |
| `CRONTAB_SETTINGS`                 | Not set          | Define cron jobs directly via environment variable. |
| `CRONTAB_SHELL`                    | `/bin/bash`      | Default shell for cron jobs. |
| `CRONTAB_TZ`                       | `$TZ`            | Timezone used for cron jobs. |

## Tuning and Apache

| Setting Name | Default Value | Description |
|---|---|---|
| `ENABLE_TUNING_FPM`                | Not enabled      | Enable automatic tuning of PHP-FPM settings when set to `1`. Uses the CPU limit of the container, or the host CPU count if there is none. A `PHP_PM*` variable you pass replaces the tuned value. See [Customizing PHP-FPM](#customizing-php-fpm). |
| `ENABLE_TUNING_MPM`                | Not enabled      | Enable automatic tuning of Apache MPM settings when set to `1`. Uses the CPU and memory limits of the container, or the host values if there are none. |
| `APACHE_ALLOW_OVERRIDE`            | `all`            | Value of `AllowOverride` for the document root. `none` skips reading `.htaccess` files on every request, but rules in `.htaccess` stop working. |
| `APACHE_DEFLATE_LEVEL`             | `5`              | Compression level of `mod_deflate`, from 1 (fast) to 9 (smallest). |
| `APACHE_DISABLE_MODULES`           | Not set          | Apache modules to turn off at start, separated by spaces. |
| `APACHE_EXPIRES`                   | `access plus 1 month`| Cache lifetime that `mod_expires` sets for static file types such as CSS, JS, images and fonts. |
| `APACHE_KEEPALIVE_TIMEOUT`         | `120`            | Seconds that Apache keeps an idle connection open. Keep it longer than the idle time of the proxy in front (Traefik: 90 s), or the proxy can reuse a connection that just closed and answer 502. |
| `NGINX_KEEPALIVE_TIMEOUT`          | `120`            | The same for Nginx (`keepalive_timeout`). `0` turns keep-alive off. |
| `APACHE_MPM_PROFILE`               | `balanced`       | Profile used by `ENABLE_TUNING_MPM`: `low`, `balanced` or `high`. |
| `APACHE_REFERRER_POLICY`           | `strict-origin-when-cross-origin` | Value of the `Referrer-Policy` response header. |
| `APACHE_REQUEST_READ_TIMEOUT`      | `header=0 body=0` (no limit) | Value of `RequestReadTimeout`. Set a limit to close connections that send the request too slowly. |

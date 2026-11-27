# shinsenter/rector

♻️ (PHP) Upgrade your project to a newer PHP version with Rector, in one step

- Docker Hub: https://hub.docker.com/r/shinsenter/rector
- GitHub Packages: https://code.shin.company/php/pkgs/container/rector
- Main documentation (all environment variables, PHP extensions, hooks, cron): [shinsenter/php](https://hub.docker.com/r/shinsenter/php)
- Other pre-built images for popular PHP apps and frameworks: https://hub.docker.com/u/shinsenter

Built on [shinsenter/php](https://hub.docker.com/r/shinsenter/php) (`8.6-cli`) with the latest [Rector](https://getrector.com/documentation) at build time. There is no web server in this image.


## Quick start

Mount your project at `/app`, say which PHP version you want, and run:

```shell
docker run --rm \
    -v ./my-project:/app \
    -e RECTOR_TARGET_PHP=8.6 \
    shinsenter/rector:latest
```

The container asks nothing. It does these steps and exits:

1. Checks that `/app` is a PHP project (a `composer.json`, or `.php` files).
2. Stops with "nothing to upgrade" when `composer.json` already requires the target PHP version or higher.
3. Creates the branch `migration-to-php-8.6` from the current commit.
4. Runs Rector in dry-run mode and saves the diff and the JSON result in `.rector-report/`.
5. Applies the changes to your files.
6. Raises `require.php` in `composer.json` to `^8.6`.

Nothing is committed or pushed. Review the result, then commit it yourself:

```shell
cd my-project
git diff                      # what changed
ls .rector-report             # reports saved before the change
git commit -am "chore: upgrade to PHP 8.6"
```

To undo everything, delete the branch:

```shell
git checkout - && git branch -D migration-to-php-8.6
```


## Before you run it

- With git: the working tree must be clean. Commit or stash your work first, or set `RECTOR_ALLOW_DIRTY=1` to carry the uncommitted changes onto the new branch. The branch name must not exist yet. Set `RECTOR_BRANCH` to use another name.
- Without git (no repository, or Subversion): the container changes your files in place and saves the originals first. See "No git" below.
- Rector reads your code, it does not run it. You do not need your `vendor/` folder or a database.
- The container writes files as the owner of the mounted folder, so files on the host keep their owner. Set `APP_UID` and `APP_GID` to choose another owner.


## Settings

Set them with `-e NAME=value`.

| Variable | What it does | Default |
|---|---|---|
| `RECTOR_TARGET_PHP` | PHP version to upgrade to, `<major>.<minor>` from 5.6 to 8.6. Required. | not set |
| `RECTOR_PROJECT_PATH` | Folder of your project inside the container. | `/app` |
| `RECTOR_BRANCH` | Name of the new branch. | `migration-to-php-<version>` |
| `RECTOR_ALLOW_DIRTY` | `1` runs on a working tree with uncommitted changes. | `0` |
| `RECTOR_UPDATE_COMPOSER` | `0` leaves `composer.json` alone. By default `require.php` becomes `^<version>` when it allows an older PHP. | `1` |
| `RECTOR_FORCE` | `1` skips the check "project already requires this PHP version". | `0` |
| `RECTOR_PATHS` | Folders or files to upgrade, comma-separated, relative to the project. Default config only. | existing folders among `app`, `src`, `lib`, `config`, `public`, `tests`; the project root when none exist |
| `RECTOR_SKIP` | Folders or files to skip, comma-separated, relative to the project. Default config only. | `vendor`, `node_modules` |
| `RECTOR_ARGS` | Extra flags for `rector process`, for example `--debug`. Split on spaces. | not set |
| `RECTOR_MEMORY_LIMIT` | Rector memory limit, for example `2G`. | Rector default |
| `RECTOR_BACKUP_EXISTING` | No git only. A backup from an earlier run exists: `keep` leaves the originals it holds, `recreate` deletes it and saves the files again from the working folder. | `keep` |
| `RECTOR_REPORT_DIR` | Where the reports are saved. | `<project>/.rector-report` |

The report folder is added to `.git/info/exclude`, so `git status` shows only the upgrade.


## No git

When the project is not a git repository (or is under Subversion), the container does not stop. It runs in place and prints a warning:

1. After the dry run, it copies the original of every file Rector will change to `.rector-report/backup/files/`, with the same paths.
2. It writes the script `.rector-report/backup/restore`.
3. It applies the changes. No branch is made and nothing is committed.

Put everything back as it was:

```shell
sh my-project/.rector-report/backup/restore
```

The script copies the saved files over the project. Give it a folder if the project is elsewhere: `sh restore /path/to/project`. Files that Rector creates are not removed.

If `.rector-report/backup/` already exists from an earlier run, the container keeps the originals it holds and adds only the files it does not have yet. That keeps the first originals safe when you run again on an upgraded project. To start fresh from the current files instead, set `RECTOR_BACKUP_EXISTING=recreate`. This replaces the saved originals with the current files, so use it only when the project is in the state you want to save.

The backup holds only the files Rector changes. It does not replace version control. For Subversion, review the result with `svn diff` and undo with `svn revert`.


## Your own Rector config

Without a `rector.php`, the image generates one that applies the Rector sets for every PHP version up to your target, and tells Rector the project is on the target version, plus the Rector sets `deadCode` and `codeQuality`. These remove unused code and tidy docblocks and expressions, so the diff has more than the version upgrade. The rule that adds `declare(strict_types=1)` is skipped, because it changes how PHP checks types at run time. To get the version upgrade only, use your own `rector.php`.

To use your own, create `rector.php` in the root of your project (the folder you mount at `/app`), following the [Rector manual](https://getrector.com/documentation). The container reads it at start. Example:

```php
<?php
use Rector\Config\RectorConfig;

return RectorConfig::configure()
    ->withPaths([__DIR__ . '/src'])
    ->withPhpSets(php86: true)
    ->withPreparedSets(deadCode: true, codeQuality: true);
```

`__DIR__` is your project folder, so paths like `__DIR__ . '/src'` work. Run the image as usual, with nothing else to mount.

With your own config, `RECTOR_TARGET_PHP` only names the branch and drives the "already upgraded" check. `RECTOR_PATHS` and `RECTOR_SKIP` do not apply. `RECTOR_ARGS` and `RECTOR_MEMORY_LIMIT` still do.


## What you get

After a run, `.rector-report/` holds:

| File | Content |
|---|---|
| `rector-version.txt` | The Rector version that ran. |
| `rector.diff` | The planned changes as a diff, from the dry run. |
| `rector.json` | The same result as JSON, for tools. |
| `rector-apply.log` | The output of the run that changed your files. |

`composer.json` is changed in place, so its format stays. Only `require.php` changes. `require-dev`, `config.platform.php` and `composer.lock` are not touched: run `composer update` yourself and check that your packages support the new PHP.

The container prints the branch (or the backup path without git), the config, the number of changed files and the report path.

Exit codes:

| Code | Meaning |
|---|---|
| `0` | Done, or nothing to upgrade. |
| `1` | Stopped before changing anything: wrong version, not a PHP project, dirty tree, branch exists, or the list of files to back up is missing. |
| other | Rector failed. The branch and files stay as they are, so you can look at them. |


## Examples

Use a project folder other than `/app`:

```shell
docker run --rm -v ./my-project:/work -e RECTOR_PROJECT_PATH=/work -e RECTOR_TARGET_PHP=8.6 shinsenter/rector:latest
```

Upgrade only `src` and `app`, and skip generated code:

```shell
docker run --rm -v ./my-project:/app \
    -e RECTOR_TARGET_PHP=8.6 \
    -e RECTOR_PATHS=src,app \
    -e RECTOR_SKIP=src/Generated \
    shinsenter/rector:latest
```

Big project, more memory and a debug log:

```shell
docker run --rm -v ./my-project:/app \
    -e RECTOR_TARGET_PHP=8.6 -e RECTOR_MEMORY_LIMIT=4G -e RECTOR_ARGS=--debug \
    shinsenter/rector:latest
```

Compose:

```yaml
services:
  rector:
    image: shinsenter/rector:latest
    environment:
      RECTOR_TARGET_PHP: "8.6"
    volumes:
      - ./my-project:/app
```

To run it again on the same project, delete the old branch first, because its name is taken.


## If something stops

| Message | What to do |
|---|---|
| `set RECTOR_TARGET_PHP to <major>.<minor>` | Pass `-e RECTOR_TARGET_PHP=8.6`. |
| `is not a PHP project` | The mount is wrong or points to the wrong level of a monorepo. Check the `-v` path. |
| `RECTOR_PATHS has no PHP files` | A folder in `RECTOR_PATHS` is empty or does not exist. |
| `nothing to upgrade` | `composer.json` already requires this version or higher. Set `RECTOR_FORCE=1` to run anyway. |
| `cannot read the PHP version` (warning) | There is no `require.php` in `composer.json`, or the constraint has no lower bound. The run goes on. |
| `is not a git repository` (warning) | The run goes on in place, with a backup. See "No git". |
| `cannot list the files to back up` | Rector found changes but the container could not read which files. Nothing was changed. Open `.rector-report/rector.diff` and report it. |
| `uncommitted changes found` | Commit or stash, or set `RECTOR_ALLOW_DIRTY=1`. |
| `branch ... already exists` | Delete the old branch or set `RECTOR_BRANCH`. |
| Rector runs out of memory | Raise `RECTOR_MEMORY_LIMIT`. |

What the image does not do: change `composer.lock` or the other packages, run your tests, fix problems that Rector has no rule for, commit or push. Review the diff and run your tests before you merge.


## What is inside

| Item | Value |
|---|---|
| Base image | [shinsenter/php](https://hub.docker.com/r/shinsenter/php) `8.6-cli`, Debian and Alpine |
| Rector | latest at build time, installed in `/var/www/html` |
| Tools | `git`, PHP, and Composer from the base image |
| Needs network at start | no |

Rector is fixed when the image is built, so a new Rector release shows up in the next rebuild. The same image tag gives the same rules each time. To use another Rector version, build the image from [`src/utilities/rector/rector.dockerfile`](https://code.shin.company/php/blob/main/src/utilities/rector/rector.dockerfile) with `--build-arg RECTOR_VERSION=<version>`.


## Image tags and platforms

- All tags and platforms: [Docker Hub](https://hub.docker.com/r/shinsenter/rector/tags). Debian and Alpine variants are available.
- The image exists for PHP 8.6 only.
- Images are rebuilt when PHP, the base OS or Rector publish an update, so a tag can change over time. For production, pin your own copy:

```shell
docker pull shinsenter/rector:latest
docker tag  shinsenter/rector:latest your-repo/rector:stable
docker push your-repo/rector:stable
```


## Support the project

Keeping these images rebuilt for every PHP release takes ongoing work. If they save you time, you can help keep them going:

- ☕ [Donate via PayPal](https://www.paypal.me/shinsenter)
- 💖 [Sponsor on GitHub](https://github.com/sponsors/shinsenter)

Reporting a bug, sharing the project or giving it a star on [GitHub](https://code.shin.company/php) also helps.


## Issues and license

- Questions and bugs: [GitHub issues](https://code.shin.company/php/issues/new).
- Licensed under the [GNU General Public License v3.0](https://code.shin.company/php/blob/main/LICENSE). If you reuse ideas from this project, please give credit.

---

From Vietnam 🇻🇳 with love.

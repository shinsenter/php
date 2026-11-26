<!--
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
-->

# Proposal: Rector one-step upgrade image

## Why

Upgrading a project to a newer PHP needs Rector, Composer and a matching PHP on the host.
An image that holds all of it turns the upgrade into one `docker run`.

## Scope

- New image `rector`, built on `php8.6-cli`. The build installs the latest Rector into `$APP_ROOT`, so a start needs no network.
- The user mounts the project at `/app` (path set by env), sets the target PHP version, runs the container.
- The container creates a branch, writes the Rector output as report files, then applies the upgrade. It asks nothing and never commits.
- The user can put a `rector.php` in the project and tune Rector through environment variables.
- Without a `rector.php`, the image generates a config with `withPhpSets()` for the target, which adds the Rector sets of every PHP version up to it (5.6 to 8.6 covers 7.0, 7.1, ..., 8.5, 8.6). It also tells Rector the project is on the target PHP (`withPhpVersion`), so rules of the target version apply.
- After the upgrade, `require.php` in `composer.json` is raised to `^<target>`. `RECTOR_UPDATE_COMPOSER=0` turns this off.

Out of scope: commits, pushing the branch, `composer.lock` and other packages, running the project's tests, framework-specific sets.

## Open points

- Image path (`src/utilities/rector/`). Unverified.
- Whether `$APP_ROOT` (document root, set by `app-root`) is writable and empty in the `cli` image. Unverified.
- Rector flags for reports and baseline (`--output-format`, `--generate-baseline`). `--output-format` is verified, the baseline is not used.
- Adding the per-version set files (`config/set/php<NN>.php`) one by one, from the project's PHP to the target, was tried and dropped: Rector 2.9 marks them deprecated and prints a warning for each. `withPhpSets()` is the supported way, and it always starts from the oldest set.
- "Latest" is fixed at build time. A new Rector release needs a rebuild; whether the `Watch updates` workflow can trigger it is Unverified.
